/* =============================================================================

                  ██╗   ██╗██╗  ██╗ ██████╗ ███╗   ██╗██╗  ██╗
                  ██║   ██║██║ ██╔╝██╔═══██╗████╗  ██║╚██╗██╔╝
                  ██║   ██║█████╔╝ ██║   ██║██╔██╗ ██║ ╚███╔╝
                  ██║   ██║██╔═██╗ ██║   ██║██║╚██╗██║ ██╔██╗
                  ╚██████╔╝██║  ██╗╚██████╔╝██║ ╚████║██╔╝ ██╗
                   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝

  File name:    main.c
  Date:         03 02 2019
  Author:       Power.
  Description:  MOD Converter - Body file.

============================================================================= */

/* =============================================================================
                                 DEBUG Section
============================================================================= */


/* =============================================================================
                                 Include Files
============================================================================= */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>


/* =============================================================================
                          Private defines and typedefs
============================================================================= */
#define WAV_FILE "sample.wav"

#define WAVE_GROUP_ID           "RIFF"
#define WAVE_RIFF_TYPE          "WAVE"
#define WAVE_FMT_ID             "fmt"
#define WAVE_SOUND_DATA_ID      "data"

#define WAVE_FORMAT_PCM 	      0x0001  // PCM
#define WAVE_FORMAT_IEEE_FLOAT  0x0003 	// IEEE float
#define WAVE_FORMAT_ALAW 	      0x0006 	// 8-bit ITU-T G.711 A-law
#define WAVE_FORMAT_MULAW 	    0x0007 	// 8-bit ITU-T G.711 µ-law
#define WAVE_FORMAT_EXTENSIBLE 	0xFFFE 	// Determined by SubFormat

#define DMA_LOAD(r,d)           ( (uint16_t)( ( ((r) & 0x0f)<<8) | ((d) & 0xff) ) )
#define DMA_PAUSE(n)            ( (uint16_t)(0x1000 | ((n) & 0x0FFF) ) )
#define DMA_REPEAT(n)           ( (uint16_t)(0x2000 | ((n) & 0x0FFF) ) )
#define DMA_NOP()               ( (uint16_t)0x4000 )
#define DMA_LOOP()              ( (uint16_t)0x4001 )
#define DMA_INT()               ( (uint16_t)0x4010 )
#define DMA_STOP()              ( (uint16_t)0x4020 )

typedef struct WAVE_RIFF {
  char achChunkID[4];
  uint32_t u32ChunkSize;
  char achFormat[4];
} sWaveRiff_t;

typedef struct WAVE_FMT {
  char achSubchunk1ID[4];
  uint32_t u32Subchunk1Size;
  uint16_t u16AudioFormat;
  uint16_t u16NumChannels;
  uint32_t u32SampleRate;
  uint32_t u32ByteRate;
  uint16_t u16BlockAlign;
  uint16_t u16BitsPerSample;
} sWaveFmt_t;

typedef struct WAVE_DATA {
  char achSubchunk2ID[4];
  uint32_t u32Subchunk2Size;
} sWaveData_t;


/* =============================================================================
                        Private constants and variables
============================================================================= */

static const uint8_t g_cau8PSGVolumeLUT[] =
{
     0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2
  ,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,  5,  5,  5
  ,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  7
  ,  7,  7,  7,  7,  7,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8
  ,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9
  , 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
  , 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
  , 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
  , 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
  , 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
  , 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
  , 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
  , 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
  , 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
  , 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
  , 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
};
static sWaveRiff_t g_sRiff;
static sWaveFmt_t g_sFmt;
static sWaveData_t g_sData;
static uint8_t *g_au8WaveData = NULL;

/* =============================================================================
                        Private function declarations
============================================================================= */
static int iLoadFile (char *p_achFilename);
static int iConvertData (char *p_achFilename);
static uint8_t u8ConvertSample_u8 (uint8_t p_u8Sample);


/* =============================================================================
                               Public functions
============================================================================= */


/*==============================================================================
Function    : main

Describe    : Program entry point.

Parameters  : Don't care.

Returns     : Don't care.
==============================================================================*/
int main (int argc, char *argv[])
{
  /* Locals variables declaration. */
  int l_iReturn = 0;

  assert (argc == 2);

  /* Load wave file into memory. */
  iLoadFile ("Loop.wav");
  //iLoadFile (argv[1]);

  /* Convert data and save result. */
  iConvertData (argv[1]);
  //iConvertData ("Loop.wav");

  /* free resources. */
  free (g_au8WaveData);

  printf ("Done !\n");

  return (l_iReturn);
}


/* =============================================================================
                              Private functions
============================================================================= */

/*==============================================================================
Function    : iLoadFile

Describe    : .

Parameters  : .

Returns     : .
==============================================================================*/
static int iLoadFile (char *p_achFilename)
{
  /* Locals variables declaration. */
  int l_iReturn           = 0;
  FILE *l_fpMod           = NULL;
  uint32_t l_u32Read      = 0u;
  uint32_t l_u32FileSize  = 0u;

  /* Open file. */
  l_fpMod = fopen (p_achFilename, "rb");
  assert (NULL != l_fpMod);

  /* Get file size. */
  fseek (l_fpMod, 0L, SEEK_END);
  l_u32FileSize = ftell (l_fpMod);
  rewind (l_fpMod);

  assert (l_u32FileSize > (sizeof (g_sRiff) + sizeof (g_sFmt) + sizeof (g_sData) ) );

  /* Read header. */
  l_u32Read = fread (&g_sRiff, 1u, sizeof (g_sRiff), l_fpMod);
  assert (sizeof (g_sRiff) == l_u32Read);
  assert (0 == strncmp (g_sRiff.achChunkID, WAVE_GROUP_ID, strlen (WAVE_GROUP_ID) ) );
  assert (0 == strncmp (g_sRiff.achFormat, WAVE_RIFF_TYPE, strlen (WAVE_RIFF_TYPE) ) );
  l_u32Read = fread (&g_sFmt, 1u, sizeof (g_sFmt), l_fpMod);
  assert (sizeof (g_sFmt) == l_u32Read);
  assert (0 == strncmp (g_sFmt.achSubchunk1ID, WAVE_FMT_ID, strlen (WAVE_FMT_ID) ) );
  l_u32Read = fread (&g_sData, 1u, sizeof (g_sData), l_fpMod);
  assert (sizeof (g_sData) == l_u32Read);
  assert (0 == strncmp (g_sData.achSubchunk2ID, WAVE_SOUND_DATA_ID, strlen (WAVE_SOUND_DATA_ID) ) );

  /* Allocate memory for data. */
  g_au8WaveData = (uint8_t *)malloc(g_sData.u32Subchunk2Size);
  assert (NULL != g_au8WaveData);

  /* Read data. */
  l_u32Read = fread (g_au8WaveData, 1u, g_sData.u32Subchunk2Size, l_fpMod);
  assert (g_sData.u32Subchunk2Size == l_u32Read);

  fclose (l_fpMod);

  return (l_iReturn);
}


/*==============================================================================
Function    : iConvertData

Describe    : .

Parameters  : .

Returns     : .
==============================================================================*/
static int iConvertData (char *p_achFilename)
{
  /* Locals variables declaration. */
  int l_iReturn           = 0;
  FILE *l_fp              = NULL;
  uint16_t l_u16Counter   = 0u;
  uint8_t l_u8LastConvert = 0xff;
  uint16_t l_u16Index     = 0u;

  l_fp = fopen ("dma.asm", "wt");

  fprintf (l_fp, "; %s\n", strrchr (p_achFilename, '\\') );
  fprintf (l_fp, "  dw &%04X\n", DMA_REPEAT(10) );

  /* Initialize with first value. */
  l_u8LastConvert = u8ConvertSample_u8 (g_au8WaveData[0]);
  fprintf (l_fp, "  dw &%04X\n",  DMA_LOAD(9, l_u8LastConvert));

  do
  {
    if ( l_u8LastConvert != u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) )
    {
      if (0u < l_u16Counter)
      {
        while (0u < (l_u16Counter / 0xFFF) )
        {
          fprintf (l_fp, "  dw &%04X\n", DMA_PAUSE (0xFFF) );
          l_u16Counter -= 0xFFF;
        }
        fprintf (l_fp, "  dw &%04X\n", DMA_PAUSE(l_u16Counter) );
      }

      fprintf (l_fp, "  dw &%04X\n", DMA_LOAD(9, u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) ) );
      l_u16Counter  = 0u;
      l_u8LastConvert = u8ConvertSample_u8 (g_au8WaveData[l_u16Index]);
    }
    else
    {
      l_u16Counter++;
    }
    l_u16Index++;
  }
  while (l_u16Index <= g_sData.u32Subchunk2Size );

  fprintf (l_fp, "  dw &%04X\n", DMA_LOOP() );
  fprintf (l_fp, "  dw &%04X\n", DMA_STOP() );

  fclose (l_fp);

  return (l_iReturn);
}


/*==============================================================================
Function    : u8ConvertSample_u8

Describe    : Convert 8 bit sample to 4 bit PSG sample.

Parameters  : p_u8Sample = 8 Bit sample.

Returns     : 4 bit PSG sample.
==============================================================================*/
static uint8_t u8ConvertSample_u8 (uint8_t p_u8Sample)
{
  /* Locals variables declaration. */
  int16_t l_s16Sample;
  uint8_t l_u8Convert;

  l_s16Sample = (int8_t)(p_u8Sample - 128);
  if (l_s16Sample >= 0)
  {
    l_u8Convert = g_cau8PSGVolumeLUT[(uint8_t)(l_s16Sample*1.8)]>>1;
    l_u8Convert += 7;
  }
  else
  {
    l_s16Sample = -l_s16Sample;
    l_u8Convert = 7;
    l_u8Convert -= (g_cau8PSGVolumeLUT[(uint8_t)(l_s16Sample*1.8)]>>1);
  }

  return (l_u8Convert);
}


