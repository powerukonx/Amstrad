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
#include <string.h>
#include <stdint.h>
#include <assert.h>


/* =============================================================================
                          Private defines and typedefs
============================================================================= */
#define MOD_FILENAME            "bomb-pass_remix_i.mod"
#define MOD_TITLE_LENGTH        ((uint8_t)20)
#define MOD_SAMPLE_NAME_LENGTH  ((uint8_t)22)
#define MOD_MAX_INSTRUMENT      ((uint8_t)31)
#define MOD_MAX_SONG_POSITIONS  ((uint8_t)128)
#define MOD_MAGIC_LENGTH        ((uint8_t)4)
#define MOD_LINE_PER_PATTERN    ((uint8_t)64)
#define MOD_CHANNEL_LENGTH      ((uint8_t)4)

#define CPC_NB_OF_BANK          ((uint8_t)4)
#define CPC_BANK_LENGTH         ((uint16_t)16384)
#define CPC_BANK_ADDRESS        ((uint16_t)0x4000)
#define CPC_BANK_FIRST_BANK     ((uint8_t)0xC4)

#define WORD_GET_HIGHBYTE(d)    ( ((d) >> 8u) & 0xFFu)
#define WORD_GET_LOWBYTE(d)     ((d) & 0xFFu)

#define MAKE_WORD(m,l)          ( ( ((m) & 0xffu) << 8u) | ((l) & 0xffu) )

#define MOD_CHANNEL_1           0u
#define MOD_CHANNEL_2           (MOD_CHANNEL_1 + 1u)
#define MOD_CHANNEL_3           (MOD_CHANNEL_2 + 1u)
#define MOD_CHANNEL_4           (MOD_CHANNEL_3 + 1u)
#define MOD_CHANNEL_5           (MOD_CHANNEL_4 + 1u)
#define MOD_CHANNEL_6           (MOD_CHANNEL_5 + 1u)
#define MOD_CHANNEL_7           (MOD_CHANNEL_6 + 1u)
#define MOD_CHANNEL_8           (MOD_CHANNEL_7 + 1u)

#define CPC_MOD_HEADER_OFFSET   0u

/* Select channel to remove. */
#define CPC_MOD_CHANNEL_REMOVED MOD_CHANNEL_3


/* =============================================================================
                        Private constants and variables
============================================================================= */

/* Sample value -> PSG value conversion LUT. */
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

/* MOD Header, big endian format. */
static struct
{
  char achTitle[MOD_TITLE_LENGTH];

  struct
  {
    char achName[MOD_SAMPLE_NAME_LENGTH];
    uint8_t au8Length[sizeof(uint16_t)];
    uint8_t u8FineTune;
    uint8_t u8Volume;
    uint8_t au8LoopStart[sizeof(uint16_t)];
    uint8_t au8LoopStop[sizeof(uint16_t)];
  } sInstrument[MOD_MAX_INSTRUMENT];

  uint8_t u8SongLength;
  uint8_t u8RestartPosition;

  uint8_t au8SongPositions[MOD_MAX_SONG_POSITIONS];
  char achMagic[MOD_MAGIC_LENGTH];
} g_sHeader;

/* 31 Instruments max. */
static uint8_t *g_pau8Sample[MOD_MAX_INSTRUMENT]                =
{
  NULL
};

static uint8_t g_u8NbOfChannel                                  = 0u;
static uint8_t g_u8NbOfPattern                                  = 0u;
static uint8_t g_au8BankMemory[CPC_NB_OF_BANK][CPC_BANK_LENGTH] =
{
  0u
};

static uint16_t g_au16BankFreeSpace[CPC_NB_OF_BANK]             =
{
    CPC_BANK_LENGTH
  , CPC_BANK_LENGTH
  , CPC_BANK_LENGTH
  , CPC_BANK_LENGTH
};


/* =============================================================================
                        Private function declarations
============================================================================= */
static inline void savenote (uint16_t p_u16SamplePeriod, FILE *p_fp);
static inline void savesamplenb (uint8_t p_u8SampleNumber, FILE *p_fp);
static inline void savefx (uint8_t p_u8Fx, uint8_t p_u8FxParam, FILE *p_fp);
static inline uint8_t u8ConvertToNote (uint16_t p_u16SamplePeriod);

/* =============================================================================
                               Public functions
============================================================================= */

/*==============================================================================
Function    : main

Describe    : Program entry point.

Parameters  : None.

Returns     : Don't care.
==============================================================================*/
int main ()
{
  /* Locals variables declaration .*/
  FILE *l_fpMod = NULL;
  uint32_t l_u32FileSize = 0u;
  uint16_t l_u16OnePatternLength = 0u;
  uint32_t l_u32TotalPatternLength = 0u;
  uint8_t *l_pau8Pattern = NULL;
  char l_achTemp[128];
  uint16_t l_au16PatternAddress[256] = {0u};
  uint8_t l_u8Offset = 0u;
  uint8_t *l_pau8Snapshot = NULL;

  /* Clear header content. */
  memset (&g_sHeader, 0u, sizeof (g_sHeader) );

  /* Clear CPC banks. */
  memset (g_au8BankMemory, 0u, sizeof (g_au8BankMemory) );

  /* Open MOD file. */
  l_fpMod = fopen (MOD_FILENAME, "rb");
  if (NULL == l_fpMod)
  {
    printf ("Can't open file: %s\r\n", MOD_FILENAME);
    exit (0);
  }

  /* Get file size. */
  fseek (l_fpMod, 0L, SEEK_END);
  l_u32FileSize = ftell (l_fpMod);
  rewind (l_fpMod);

  /* Read header. */
  fread (&g_sHeader, 1,  sizeof (g_sHeader), l_fpMod);

  if (0 == strcmp ("2CHN", g_sHeader.achMagic) ) /* FastTracker 2 Channel MODs */
  {
    g_u8NbOfChannel = 2;
  }
  else if (0 == strcmp ("M.K.", g_sHeader.achMagic) )
  {
    g_u8NbOfChannel = 4;
  }
  else if (0 == strcmp ("4CHN", g_sHeader.achMagic) )
  {
    g_u8NbOfChannel = 4;
  }
  else if (0 == strcmp ("6CHN", g_sHeader.achMagic) )
  {
    g_u8NbOfChannel = 6;
  }
  else if (0 == strcmp ("8CHN", g_sHeader.achMagic) )
  {
    g_u8NbOfChannel = 8;
  }
  else if (0 == strcmp ("FLT4", g_sHeader.achMagic) ) /* Startrekker 4 channels file */
  {
    g_u8NbOfChannel = 4;
  }
  else if (0 == strcmp ("CD81", g_sHeader.achMagic) ) /* Falcon 8 channels MODs */
  {
    g_u8NbOfChannel = 8;
  }
  else if (0 == strcmp ("FLT8", g_sHeader.achMagic) ) /* Startrekker 8 channels file */
  {
    g_u8NbOfChannel = 8;
  }
  else if (0 == strcmp ("OCTA", g_sHeader.achMagic) )
  {
    g_u8NbOfChannel = 8;
  }
  else
  {
    fclose(l_fpMod);
    assert (0);
  }

  /* Compute one pattern length. */
  l_u16OnePatternLength = g_u8NbOfChannel * MOD_CHANNEL_LENGTH * MOD_LINE_PER_PATTERN ;

  /* Compute number of pattern. */
  l_u32TotalPatternLength = l_u32FileSize - sizeof(g_sHeader);
  for (uint32_t l_u32Index = 0u; l_u32Index < MOD_MAX_INSTRUMENT; l_u32Index++)
  {
    uint16_t l_u16Length = (g_sHeader.sInstrument[l_u32Index].au8Length[0]<<8)|g_sHeader.sInstrument[l_u32Index].au8Length[1];
    if (l_u16Length > 1u)
    {
      l_u16Length <<= 1u;
      l_u32TotalPatternLength -= l_u16Length;

      /* Allocate memory for instrument. */
      g_pau8Sample[l_u32Index] = (uint8_t *) malloc (l_u16Length);
    }
  }
  g_u8NbOfPattern = l_u32TotalPatternLength / l_u16OnePatternLength;

  /* Allocate memory for patterns. */
  l_pau8Pattern = (uint8_t *) malloc (l_u16OnePatternLength * g_u8NbOfPattern);
  assert (NULL != l_pau8Pattern);

  /* Read patterns. */
  fread (l_pau8Pattern, 1u,  (l_u16OnePatternLength * g_u8NbOfPattern), l_fpMod);

  /* Extract and save pattern data for debug. */
  for (uint8_t l_u8PatternIndex = 0u; l_u8PatternIndex < g_u8NbOfPattern; l_u8PatternIndex++)
  {
    FILE *fpPattern = NULL;
    sprintf (l_achTemp, "extract/pattern%d.txt", l_u8PatternIndex);
    fpPattern = fopen (l_achTemp, "wt");
    assert (NULL != fpPattern);

    for (uint8_t l_u8LineIndex = 0u; l_u8LineIndex < MOD_LINE_PER_PATTERN; l_u8LineIndex++)
    {
      for (uint8_t l_u8ChannelIndex = 0u ; l_u8ChannelIndex < g_u8NbOfChannel; l_u8ChannelIndex++)
      {
        uint32_t u32Offset = (l_u16OnePatternLength * l_u8PatternIndex);
        u32Offset += (l_u8LineIndex * MOD_CHANNEL_LENGTH * g_u8NbOfChannel);
        u32Offset += (l_u8ChannelIndex * g_u8NbOfChannel);

        uint8_t l_u8SampleNumber    = l_pau8Pattern[u32Offset]&0xf0;
        uint16_t l_u16SamplePeriod  = (l_pau8Pattern[u32Offset]&0x0f)<<8;
        l_u16SamplePeriod          |= l_pau8Pattern[u32Offset + 1];

        l_u8SampleNumber           |= ((l_pau8Pattern[u32Offset + 2]>>4)&0x0f);

        uint8_t l_u8Fx              = l_pau8Pattern[u32Offset + 2]&0x0f;
        uint8_t l_u8FxParam         = l_pau8Pattern[u32Offset + 3];

        savenote (l_u16SamplePeriod, fpPattern);
        fprintf (fpPattern, " ");
        savesamplenb (l_u8SampleNumber, fpPattern);
        fprintf (fpPattern, " ");
        savefx (l_u8Fx, l_u8FxParam, fpPattern);
        fprintf (fpPattern, " | ");
      }
      fprintf (fpPattern, "\r\n");
    }

    fclose(fpPattern);
  }

  /*
   * Conversion to CPC format
   *
   * Pattern organization
   *
   * PC/AMIGA
   *     +---------------+---------------+---------------+---------------+
   * bit |3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
   * no. |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
   *     +---------------+---------------+---------------+---------------+
   *           | \_____________________/ \_____/ \_____/ \_____________/
   *         Sample     Period            Sample  Effect    Parameter
   *           High                         Low
   *
   * CPC
   *     +---------------+---------------+---------------
   * bit 7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|
   *     +---------------+---------------+---------------
   *     \___/ \_______/ |  \_________/ \_____________/
   *     FxLSB   Sample  Fx     Note       Parameter
   *                     MSB
   *
   * CPC Memory organisation (Bank C4)
   *
   * Offset    Size    Description
   *
   * 0000        2     Sample 1 addr
   * 0002        1     Sample 1 RAM bank
   * 0004        2     Sample 1 size
   * 0006       ...    others 30 instruments
   * 009B        1     Song length
   * 009C        2     First pattern address
   * 009E       ...    others 127 patterns
   * 019C       ...    pattern datas (127*3)
   */

  /* Copy song length. */
  uint16_t l_u16Offset = (MOD_MAX_INSTRUMENT*5);
  g_au8BankMemory[0][l_u16Offset++] = g_sHeader.u8SongLength;

  /* Convert pattern. */
  uint16_t l_u16PatternDataOffset = CPC_MOD_HEADER_OFFSET + (MOD_MAX_INSTRUMENT*5) + (MOD_MAX_SONG_POSITIONS * sizeof (uint16_t)) + sizeof (g_sHeader.u8SongLength);
  for (uint8_t l_u8PatternIndex = 0u; l_u8PatternIndex < g_u8NbOfPattern; l_u8PatternIndex++)
  {
    /* Save pattern address. */
    l_au16PatternAddress[l_u8Offset++] = l_u16PatternDataOffset + CPC_BANK_ADDRESS;

    for (uint8_t l_u8LineIndex = 0u; l_u8LineIndex < MOD_LINE_PER_PATTERN; l_u8LineIndex++)
    {
      for (uint8_t l_u8ChannelIndex = 0u; l_u8ChannelIndex < g_u8NbOfChannel; l_u8ChannelIndex++)
      {
        uint32_t l_u32ByteIndex = (l_u16OnePatternLength * l_u8PatternIndex);
        l_u32ByteIndex += (l_u8LineIndex * MOD_CHANNEL_LENGTH * g_u8NbOfChannel);
        l_u32ByteIndex += (l_u8ChannelIndex * g_u8NbOfChannel);

        uint8_t l_u8SampleNumber    = (l_pau8Pattern[l_u32ByteIndex] & 0xf0) | ( (l_pau8Pattern[l_u32ByteIndex + 2] >> 4) & 0x0f);
        uint16_t l_u16SamplePeriod  = ( (l_pau8Pattern[l_u32ByteIndex] & 0x0f)<<8) | l_pau8Pattern[l_u32ByteIndex + 1];
        uint8_t l_u8Fx              = l_pau8Pattern[l_u32ByteIndex + 2] & 0x0f;
        uint8_t l_u8FxParam         = l_pau8Pattern[l_u32ByteIndex + 3];

        if (CPC_MOD_CHANNEL_REMOVED != l_u8ChannelIndex)
        {
            /* Compress line if need. */
            if (    (0u == l_u8Fx)
                &&  (0u == l_u16SamplePeriod)
                &&  (0u == l_u8FxParam)
                &&  (0u == l_u8SampleNumber) )
            {
               g_au8BankMemory[0][l_u16PatternDataOffset++] = 0xFF;
            }
            else
            {
              g_au8BankMemory[0][l_u16PatternDataOffset]  = (l_u8Fx & 0x07u)<<5u;
              g_au8BankMemory[0][l_u16PatternDataOffset] |= (l_u8SampleNumber & 0x1Fu);

              g_au8BankMemory[0][l_u16PatternDataOffset + 1]  = (l_u8Fx & 0x08u)<<4u;
              g_au8BankMemory[0][l_u16PatternDataOffset + 1] |= (u8ConvertToNote (l_u16SamplePeriod) & 0x7fu);

              g_au8BankMemory[0][l_u16PatternDataOffset + 2] = l_u8FxParam;
              l_u16PatternDataOffset += 3u;
            }
        }
      }
    }
  }

  /* Adjust free space for C4 bank. */
  g_au16BankFreeSpace[0] -= l_u16PatternDataOffset;

  /* Copy song list. */
  for (uint8_t l_u8SongIndex = 0u; l_u8SongIndex < g_sHeader.u8SongLength; l_u8SongIndex++)
  {
    g_au8BankMemory[0][l_u16Offset++] = WORD_GET_LOWBYTE(l_au16PatternAddress[g_sHeader.au8SongPositions[l_u8SongIndex]]);
    g_au8BankMemory[0][l_u16Offset++] = WORD_GET_HIGHBYTE(l_au16PatternAddress[g_sHeader.au8SongPositions[l_u8SongIndex]]);
  }

  /* Read samples/ */
  for (uint8_t l_u8InstrumentIndex = 0u; l_u8InstrumentIndex < MOD_MAX_INSTRUMENT; l_u8InstrumentIndex++)
  {
    uint16_t l_u16Length = (g_sHeader.sInstrument[l_u8InstrumentIndex].au8Length[0]<<8)|g_sHeader.sInstrument[l_u8InstrumentIndex].au8Length[1];
    if (l_u16Length > 1u)
    {
      l_u16Length <<= 1u;

      fread (g_pau8Sample[l_u8InstrumentIndex], 1u, l_u16Length, l_fpMod);

      /* Convert data for PSG. */
      FILE *l_fpSample = NULL;
      sprintf (l_achTemp, "extract/Instrument%d.csv", l_u8InstrumentIndex+1u);
      l_fpSample = fopen (l_achTemp, "wt");
      assert (NULL != l_fpSample);
      for (uint16_t l_u16Index = 0u; l_u16Index < l_u16Length ; l_u16Index++)
      {
        int8_t l_s8Sample = (int8_t)g_pau8Sample[l_u8InstrumentIndex][l_u16Index];
        uint8_t l_u8Convert;
        if (l_s8Sample >= 0)
        {
          l_u8Convert = g_cau8PSGVolumeLUT[l_s8Sample]>>1;
          l_u8Convert += 7;
        }
        else
        {
          l_s8Sample = -l_s8Sample;
          l_u8Convert = 7;
          l_u8Convert -= (g_cau8PSGVolumeLUT[l_s8Sample]>>1);
        }

        g_pau8Sample[l_u8InstrumentIndex][l_u16Index] = l_u8Convert;

        fprintf (l_fpSample, "%d\n", l_u8Convert);
      }

      fclose(l_fpSample);
    }
  }

  /* Copy sample to virtual CPC memory. */
  l_u16Offset = 0u;
  for (uint8_t l_u8InstrumentIndex = 0u; l_u8InstrumentIndex < MOD_MAX_INSTRUMENT; l_u8InstrumentIndex++)
  {
    uint16_t l_u16Address;
    uint8_t l_u8Bank;
    uint16_t l_u16SampleLen = MAKE_WORD(g_sHeader.sInstrument[l_u8InstrumentIndex].au8Length[0u],g_sHeader.sInstrument[l_u8InstrumentIndex].au8Length[1u]);
    if (1u < l_u16SampleLen)
    {
      l_u16SampleLen <<= 1u;

      uint8_t l_u8BankIndex;
      for (l_u8BankIndex = 0; l_u8BankIndex < CPC_NB_OF_BANK; l_u8BankIndex++)
      {
        if (l_u16SampleLen < g_au16BankFreeSpace[l_u8BankIndex])
        {
          break;
        }
      }

      if (l_u8BankIndex == CPC_NB_OF_BANK)
      {
          assert(0);
      }
      else
      {
        l_u16Address = CPC_BANK_LENGTH - g_au16BankFreeSpace[l_u8BankIndex];
        l_u8Bank = l_u8BankIndex;
        g_au16BankFreeSpace[l_u8BankIndex] -= l_u16SampleLen;
      }

      memcpy (&g_au8BankMemory[l_u8Bank][l_u16Address], g_pau8Sample[l_u8InstrumentIndex], l_u16SampleLen);
      g_au8BankMemory[0u][l_u16Offset++] = WORD_GET_LOWBYTE(l_u16Address + CPC_BANK_ADDRESS);
      g_au8BankMemory[0u][l_u16Offset++] = WORD_GET_HIGHBYTE(l_u16Address + CPC_BANK_ADDRESS);
      g_au8BankMemory[0u][l_u16Offset++] = CPC_BANK_FIRST_BANK + l_u8Bank;
      g_au8BankMemory[0u][l_u16Offset++] = WORD_GET_LOWBYTE(l_u16SampleLen);
      g_au8BankMemory[0u][l_u16Offset++] = WORD_GET_HIGHBYTE(l_u16SampleLen);
    }
    else
    {
      g_au8BankMemory[0u][l_u16Offset++] = 0u;
      g_au8BankMemory[0u][l_u16Offset++] = 0u;
      g_au8BankMemory[0u][l_u16Offset++] = 0u;
      g_au8BankMemory[0u][l_u16Offset++] = 0u;
      g_au8BankMemory[0u][l_u16Offset++] = 0u;
    }
  }

  /* Close MOD file. */
  fclose (l_fpMod);

  /* Extract bank to binary file for debug. */
  for (uint8_t l_u8BankIndex = 0u; l_u8BankIndex < CPC_NB_OF_BANK; l_u8BankIndex++)
  {
    sprintf (l_achTemp, "extract/bank_%02X.bin", CPC_BANK_FIRST_BANK + l_u8BankIndex);
    FILE *l_fpBank = fopen (l_achTemp, "wb");
    fwrite (g_au8BankMemory[l_u8BankIndex], 1u, CPC_BANK_LENGTH, l_fpBank);
    fclose (l_fpBank);
  }

  /* Make .SNA 8KHz version. */
  sprintf (l_achTemp,"extract/SNA_8KHz.sna");

  FILE *l_fpFile = NULL;
  l_fpFile = fopen("8KHz.sna", "rb");
  assert (NULL != l_fpFile);
  l_pau8Snapshot = (uint8_t *)malloc(0x10100);
  assert (NULL != l_pau8Snapshot);
  fread (l_pau8Snapshot, 1u, 0x10100, l_fpFile);
  fclose (l_fpFile);

  l_fpFile = fopen(l_achTemp, "wb");
  assert (NULL != l_fpFile);
  fwrite (l_pau8Snapshot, 1u, 0x10100, l_fpFile);
  fwrite (g_au8BankMemory[0], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[1], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[2], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[3], 1u, 0x4000, l_fpFile);
  fclose (l_fpFile);

  /* Make .SNA 16KHz version. */
  sprintf (l_achTemp,"extract/SNA_16KHz.sna");

  l_fpFile = fopen("16KHz.sna", "rb");
  assert (NULL != l_fpFile);
  l_pau8Snapshot = (uint8_t *)malloc(0x10100);
  assert (NULL != l_pau8Snapshot);
  fread (l_pau8Snapshot, 1u, 0x10100, l_fpFile);
  fclose (l_fpFile);

  l_fpFile = fopen(l_achTemp, "wb");
  assert (NULL != l_fpFile);
  fwrite (l_pau8Snapshot, 1u, 0x10100, l_fpFile);
  fwrite (g_au8BankMemory[0], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[1], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[2], 1u, 0x4000, l_fpFile);
  fwrite (g_au8BankMemory[3], 1u, 0x4000, l_fpFile);
  fclose (l_fpFile);

  /* Free resources. */
  for (uint8_t l_u8InstrumentIndex = 0u; l_u8InstrumentIndex < MOD_MAX_INSTRUMENT; l_u8InstrumentIndex++)
  {
    if (NULL != g_pau8Sample[l_u8InstrumentIndex])
      free (g_pau8Sample[l_u8InstrumentIndex]);
  }
  free (l_pau8Pattern);
  free (l_pau8Snapshot);

  printf("Done!\r\n");

  return 0;
}


/* =============================================================================
                              Private functions
============================================================================= */
static inline void savenote (uint16_t p_u16SamplePeriod, FILE *p_fp)
{
  /* Locals variables declaration. */
  int l_iReturn;

  switch (p_u16SamplePeriod)
  {
    // C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
    case 856:
      l_iReturn = fprintf (p_fp, "C-3");
      break;
    case 808:
      l_iReturn = fprintf (p_fp, "C#3");
      break;
    case 762:
      l_iReturn = fprintf (p_fp, "D-3");
      break;
    case 720:
      l_iReturn = fprintf (p_fp, "D#3");
      break;
    case 678:
      l_iReturn = fprintf (p_fp, "E-3");
      break;
    case 640:
      l_iReturn = fprintf (p_fp, "F-3");
      break;
    case 604:
      l_iReturn = fprintf (p_fp, "F#3");
      break;
    case 570:
      l_iReturn = fprintf (p_fp, "G-3");
      break;
    case 538:
      l_iReturn = fprintf (p_fp, "G#3");
      break;
    case 508:
      l_iReturn = fprintf (p_fp, "A-3");
      break;
    case 480:
      l_iReturn = fprintf (p_fp, "A#3");
      break;
    case 453:
      l_iReturn = fprintf (p_fp, "B-3");
      break;

    // C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
    case 428:
      l_iReturn = fprintf (p_fp, "C-4");
      break;
    case 404:
      l_iReturn = fprintf (p_fp, "C#4");
      break;
    case 381:
      l_iReturn = fprintf (p_fp, "D-4");
      break;
    case 360:
      l_iReturn = fprintf (p_fp, "D#4");
      break;
    case 339:
      l_iReturn = fprintf (p_fp, "E-4");
      break;
    case 320:
      l_iReturn = fprintf (p_fp, "F-4");
      break;
    case 302:
      l_iReturn = fprintf (p_fp, "F#4");
      break;
    case 285:
      l_iReturn = fprintf (p_fp, "G-4");
      break;
    case 269:
      l_iReturn = fprintf (p_fp, "G#4");
      break;
    case 254:
      l_iReturn = fprintf (p_fp, "A-4");
      break;
    case 240:
      l_iReturn = fprintf (p_fp, "A#4");
      break;
    case 226:
      l_iReturn = fprintf (p_fp, "B-4");
      break;

    // C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113
    case 214:
      l_iReturn = fprintf (p_fp, "C-5");
      break;
    case 202:
      l_iReturn = fprintf (p_fp, "C#5");
      break;
    case 190:
      l_iReturn = fprintf (p_fp, "D-5");
      break;
    case 180:
      l_iReturn = fprintf (p_fp, "D#5");
      break;
    case 170:
      l_iReturn = fprintf (p_fp, "E-5");
      break;
    case 160:
      l_iReturn = fprintf (p_fp, "F-5");
      break;
    case 151:
      l_iReturn = fprintf (p_fp, "F#5");
      break;
    case 143:
      l_iReturn = fprintf (p_fp, "G-5");
      break;
    case 135:
      l_iReturn = fprintf (p_fp, "G#5");
      break;
    case 127:
      l_iReturn = fprintf (p_fp, "A-5");
      break;
    case 120:
      l_iReturn = fprintf (p_fp, "A#5");
      break;
    case 113:
      l_iReturn = fprintf (p_fp, "B-5");
      break;
    case 0:
      l_iReturn = fprintf (p_fp, "...");
      break;
    default:
      l_iReturn = fprintf (p_fp, "???");
      break;
  }

  assert (0 <= l_iReturn);
}


/*==============================================================================
Function    :

Describe    : .

Parameters  : .

Returns     : .
==============================================================================*/
static inline uint8_t u8ConvertToNote (uint16_t p_u16SamplePeriod)
{
  /* Locals variables declaration. */
  uint8_t l_u8Return = 0;

  switch (p_u16SamplePeriod)
  {
    // C-4 to B-4 : 107,101,190,90,85,80,76,71,67,64,60,57
    case 57:
      l_u8Return++;
    case 60:
      l_u8Return++;
    case 64:
      l_u8Return++;
    case 67:
      l_u8Return++;
    case 71:
      l_u8Return++;
    case 76:
      l_u8Return++;
    case 80:
      l_u8Return++;
    case 85:
      l_u8Return++;
    case 90:
      l_u8Return++;
    case 95:
      l_u8Return++;
    case 101:
      l_u8Return++;
    case 107:
      l_u8Return++;

    // C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113
    case 113:
      l_u8Return++;
    case 120:
      l_u8Return++;
    case 127:
      l_u8Return++;
    case 135:
      l_u8Return++;
    case 143:
      l_u8Return++;
    case 151:
      l_u8Return++;
    case 160:
      l_u8Return++;
    case 170:
      l_u8Return++;
    case 180:
      l_u8Return++;
    case 190:
    case 191:
      l_u8Return++;
    case 202:
      l_u8Return++;
    case 214:
      l_u8Return++;

      // C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
    case 226:
    case 227:
      l_u8Return++;
    case 240:
      l_u8Return++;
    case 254:
      l_u8Return++;
    case 269:
    case 270:
      l_u8Return++;
    case 285:
    case 286:
      l_u8Return++;
    case 302:
    case 303:
      l_u8Return++;
    case 320:
    case 321:
      l_u8Return++;
    case 339:
    case 340:
      l_u8Return++;
    case 360:
      l_u8Return++;
    case 381:
      l_u8Return++;
    case 404:
      l_u8Return++;
    case 428:
      l_u8Return++;

    // C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
    case 453:
      l_u8Return++;
    case 480:
      l_u8Return++;
    case 508:
    case 509:
      l_u8Return++;
    case 538:
      l_u8Return++;
    case 570:
      l_u8Return++;
    case 604:
      l_u8Return++;
    case 640:
      l_u8Return++;
    case 678:
      l_u8Return++;
    case 720:
      l_u8Return++;
    case 762:
      l_u8Return++;
    case 808:
      l_u8Return++;
    case 856:
      l_u8Return++;

    // C-0 to B-0 : 1712,1616,1525,1440,1357,1281,1209,1141,1077,1017,961,907
    case 907:
      l_u8Return++;
    case 961:
      l_u8Return++;
    case 1017:
      l_u8Return++;
    case 1077:
      l_u8Return++;
    case 1141:
      l_u8Return++;
    case 1209:
      l_u8Return++;
    case 1281:
      l_u8Return++;
    case 1357:
      l_u8Return++;
    case 1440:
      l_u8Return++;
    case 1525:
      l_u8Return++;
    case 1616:
      l_u8Return++;
    case 1712:
      l_u8Return++;
    case 0:
      break;
    default:
      assert (0);
      break;
  }

  return (l_u8Return);
}


/*==============================================================================
Function    :

Describe    : .

Parameters  : .

Returns     : .
==============================================================================*/
static inline void savesamplenb (uint8_t p_u8SampleNumber, FILE *p_fp)
{
  assert ( 0 <= ( (0u != p_u8SampleNumber) ? fprintf (p_fp, "%02d", p_u8SampleNumber) : fprintf (p_fp, "..") ) );
}


/*==============================================================================
Function    :

Describe    : .

Parameters  : .

Returns     : .
==============================================================================*/
static inline void savefx (uint8_t p_u8Fx, uint8_t p_u8FxParam, FILE *p_fp)
{
  assert ( 0 <= ( (0u != p_u8Fx) ? fprintf (p_fp, "%01X%02X", p_u8Fx, p_u8FxParam) : fprintf (p_fp, "...") ) );
}


