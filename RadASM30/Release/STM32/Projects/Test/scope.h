/* Includes ------------------------------------------------------------------*/
#include "stm32f4_discovery.h"
#include "window.h"
#include "video.h"

/* Private define ------------------------------------------------------------*/
#define SCOPE_MAINLEFT      0
#define SCOPE_MAINTOP       0
#define SCOPE_MAINWIDTH     480
#define SCOPE_MAINHEIGHT    239
#define SCOPE_MAINRIGHT     SCOPE_MAINLEFT+SCOPE_MAINWIDTH
#define SCOPE_MAINBOTTOM    SCOPE_MAINTOP+SCOPE_MAINHEIGHT

#define SCOPE_LEFT          4
#define SCOPE_TOP           16
#define SCOPE_WIDTH         256
#define SCOPE_HEIGHT        128+38
#define SCOPE_RIGHT         SCOPE_LEFT+SCOPE_WIDTH
#define SCOPE_BOTTOM        SCOPE_TOP+SCOPE_HEIGHT

#define ADC_ADDRESS         ((uint32_t)0x40021011)
#define SCOPE_DATAPTR       ((uint32_t)0x20010000)
#define SCOPE_DATASIZE      ((uint32_t)0x8000)

/* Private typedef -----------------------------------------------------------*/
typedef struct
{
  WINDOW* hmain;
  WINDOW* hscope;
  uint8_t markcnt;
  uint8_t markshow;
  uint8_t tmrid;
  uint8_t tmrmax;
  uint8_t tmrcnt;
  uint16_t dataofs;
  uint8_t Sample;
  uint8_t Quit;
} SCOPE;

/* Private function prototypes -----------------------------------------------*/
void ScopeMainHandler(WINDOW* hwin,uint8_t event,uint32_t param,uint8_t ID);
void ScopeHandler(WINDOW* hwin,uint8_t event,uint32_t param,uint8_t ID);
void ScopeDrawHLine(uint16_t x,uint16_t y,uint16_t wdt);
void ScopeDrawVLine(uint16_t x,uint16_t y,uint16_t hgt);
void ScopeDrawGrid(void);
void ScopeSetup(void);
void ScopeTimer(void);
