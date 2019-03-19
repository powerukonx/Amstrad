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
//#define SAVE_DMA_TXT
//#define SAVE_WAV_RESULT


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
#ifdef DBG_PWR
#define WAV_FILE                "Sample_8bit_15625Hz.wav"
#endif /* DBG_PWR */

#define AUDIO_GAIN              1.9
#define AUDIO_PSG_CHANNEL       9

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
#define DMA_NOP()               ( (uint16_t)0x4000)
#define DMA_LOOP()              ( (uint16_t)0x4001)
#define DMA_INT()               ( (uint16_t)0x4010)
#define DMA_STOP()              ( (uint16_t)0x4020)
#define DMA_PAUSE_MAX_VALUE     ( (uint16_t)0x0FFF)


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

#ifdef SAVE_WAV_RESULT
static FILE *g_psFileResult = NULL;
#endif /* SAVE_WAV_RESULT. */

/* =============================================================================
                        Private function declarations
============================================================================= */
static void vLoadFile (char *p_achFilename);
static void vConvertData (char *p_achFilename);
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

  /* Load wave file, convert data and save result.*/
#ifdef DBG_PWR
  vLoadFile (WAV_FILE);
  vConvertData (WAV_FILE);
#else
  assert (argc == 2);
  vLoadFile (argv[1]);
  vConvertData (argv[1]);
#endif /* DBG_PWR */

  /* free resources. */
  free (g_au8WaveData);

  printf ("Done !\n");

  return (l_iReturn);
}


/* =============================================================================
                              Private functions
============================================================================= */

/*==============================================================================
Function    : vLoadFile

Describe    : Load WAV file and check some parameters.

Parameters  : p_achFilename = filename nul terminated.

Returns     : None.
==============================================================================*/
static void vLoadFile (char *p_achFilename)
{
  /* Locals variables declaration. */
  FILE *l_fpMod           = NULL;
  uint32_t l_u32Read      = 0u;
  uint32_t l_u32FileSize  = 0u;

  /* Open file. */
  l_fpMod = fopen (p_achFilename, "rb");
  assert (NULL != l_fpMod);

#ifdef SAVE_WAV_RESULT
  g_psFileResult = fopen ("Result.wav", "wb");
  assert (NULL != g_psFileResult);
#endif /* SAVE_WAV_RESULT */

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

#ifdef SAVE_WAV_RESULT
  fwrite (&g_sRiff, 1u, sizeof (g_sRiff), g_psFileResult);
  fwrite (&g_sFmt, 1u, sizeof (g_sFmt), g_psFileResult);
  fwrite (&g_sData, 1u, sizeof (g_sData), g_psFileResult);
#endif /* SAVE_WAV_RESULT */

  /* Allocate memory for data. */
  g_au8WaveData = (uint8_t *)malloc(g_sData.u32Subchunk2Size);
  assert (NULL != g_au8WaveData);

  /* Read data. */
  l_u32Read = fread (g_au8WaveData, 1u, g_sData.u32Subchunk2Size, l_fpMod);
  assert (g_sData.u32Subchunk2Size == l_u32Read);

  fclose (l_fpMod);
}


/*==============================================================================
Function    : vConvertData

Describe    : Convert 8bit data to DMA instauction (4bit data).

Parameters  : p_achFilename = filename nul terminated..

Returns     : None.
==============================================================================*/
static void vConvertData (char *p_achFilename)
{
  /* Locals variables declaration. */
#ifdef SAVE_DMA_TXT
  FILE *l_fp              = NULL;
#endif /* SAVE_DMA_TXT */
  FILE *l_fp2             = NULL;
  uint16_t l_u16Counter   = 0u;
  uint8_t l_u8LastConvert = 0xff;
  uint16_t l_u16Index     = 0u;
  uint8_t l_au8Temp[64];

#ifdef SAVE_DMA_TXT
  l_fp = fopen ("dma.asm", "wt");
#ifdef DBG_PWR
  fprintf (l_fp, "; %s\n", p_achFilename);
#else
  fprintf (l_fp, "; %s\n", strrchr (p_achFilename, '\\') );
#endif /* DBG_PWR */
  fprintf (l_fp, "  dw &%04X\n", DMA_REPEAT(10) );
#endif /* SAVE_DMA_TXT */

  l_fp2 = fopen ("dma.bin", "wb");

  l_au8Temp[1] = DMA_REPEAT(10)>>8;
  l_au8Temp[0] = DMA_REPEAT(10)&0xFF;
  fwrite (l_au8Temp, 1u, sizeof (uint16_t), l_fp2);

  /* Initialize with first value. */
  l_u8LastConvert = u8ConvertSample_u8 (g_au8WaveData[0]);

  l_au8Temp[1] = DMA_LOAD(AUDIO_PSG_CHANNEL, l_u8LastConvert)>>8;
  l_au8Temp[0] = DMA_LOAD(AUDIO_PSG_CHANNEL, l_u8LastConvert)&0xFF;
  fwrite (l_au8Temp, 1u, sizeof (uint16_t), l_fp2);

#ifdef SAVE_DMA_TXT
  fprintf (l_fp, "  dw &%04X\n",  DMA_LOAD(AUDIO_PSG_CHANNEL, l_u8LastConvert) );
#endif /* SAVE_DMA_TXT */

  do
  {
#ifdef SAVE_WAV_RESULT
    /* Save result data as WAV file. */
    uint8_t u8Result = (l_u8LastConvert<<4u) + 16u;
    fwrite (&u8Result, 1u, sizeof (uint8_t), g_psFileResult);
#endif /* SAVE_WAV_RESULT */

    /* New sample is different ? */
    if ( l_u8LastConvert != u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) )
    {
      /* Insert PAUSE if need. */
      while (l_u16Counter > 0u)
      {
        if (l_u16Counter > DMA_PAUSE_MAX_VALUE)
        {
          l_au8Temp[1] = DMA_PAUSE (DMA_PAUSE_MAX_VALUE)>>8;
          l_au8Temp[0] = DMA_PAUSE (DMA_PAUSE_MAX_VALUE)&0xFF;
          fwrite(l_au8Temp, 1, sizeof(uint16_t), l_fp2);

#ifdef SAVE_DMA_TXT
          fprintf (l_fp, "  dw &%04X\n", DMA_PAUSE(DMA_PAUSE_MAX_VALUE) );
#endif /* SAVE_DMA_TXT */

          l_u16Counter -= DMA_PAUSE_MAX_VALUE;
        }
        else
        {
          l_au8Temp[1] = DMA_PAUSE (l_u16Counter)>>8;
          l_au8Temp[0] = DMA_PAUSE (l_u16Counter)&0xFF;
          fwrite(l_au8Temp, 1, sizeof(uint16_t), l_fp2);

#ifdef SAVE_DMA_TXT
          fprintf (l_fp, "  dw &%04X\n", DMA_PAUSE(l_u16Counter) );
#endif /* SAVE_DMA_TXT */

          l_u16Counter = 0u;
        }
      }

      /* Save new sample. */
      l_au8Temp[1] = DMA_LOAD(AUDIO_PSG_CHANNEL, u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) )>>8;
      l_au8Temp[0] = DMA_LOAD(AUDIO_PSG_CHANNEL, u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) )&0xFF;
      fwrite(l_au8Temp, 1, sizeof(uint16_t), l_fp2);

#ifdef SAVE_DMA_TXT
      fprintf (l_fp, "  dw &%04X\n", DMA_LOAD(AUDIO_PSG_CHANNEL, u8ConvertSample_u8 (g_au8WaveData[l_u16Index]) ) );
#endif /* SAVE_DMA_TXT */

      l_u8LastConvert = u8ConvertSample_u8 (g_au8WaveData[l_u16Index]);
    }
    else
    {
      l_u16Counter++;
    }

    l_u16Index++;
  }
  while (l_u16Index <= g_sData.u32Subchunk2Size );

#ifdef SAVE_DMA_TXT
  fprintf (l_fp, "  dw &%04X\n", DMA_LOOP() );
  fprintf (l_fp, "  dw &%04X\n", DMA_STOP() );
#endif /* SAVE_DMA_TXT */

  l_au8Temp[1] = DMA_LOOP()>>8;
  l_au8Temp[0] = DMA_LOOP()&0xFF;
  fwrite(l_au8Temp, 1, sizeof(uint16_t), l_fp2);

  l_au8Temp[1] = DMA_STOP()>>8;
  l_au8Temp[0] = DMA_STOP()&0xFF;
  fwrite(l_au8Temp, 1, sizeof(uint16_t), l_fp2);

#ifdef SAVE_WAV_RESULT
  fclose (g_psFileResult);
#endif /* SAVE_WAV_RESULT */

  fclose (l_fp2);
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
    l_u8Convert = g_cau8PSGVolumeLUT[(uint8_t)(l_s16Sample*AUDIO_GAIN)]>>1;
    l_u8Convert += 7;
  }
  else
  {
    l_s16Sample = -l_s16Sample;
    l_u8Convert = 7;
    l_u8Convert -= (g_cau8PSGVolumeLUT[(uint8_t)(l_s16Sample*AUDIO_GAIN)]>>1);
  }

  return (l_u8Convert);
}


