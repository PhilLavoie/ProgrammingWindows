module sysmets;

import std.stdio;
import std.string;
import std.conv;
import core.runtime;

import std.c.windows.windows;



//Graphics.
pragma( lib, "gdi32.lib" );
//Multimedia.
pragma( lib, "winmm.lib" );

/**
  Lines definitions.
  */
struct Metric {
  size_t index;
  immutable( char ) * label;
  size_t labelLen;
  immutable( char ) * description;  
  size_t descriptionLen;
  this( int index, string label, string description ) {
    this.index = index;
    this.label = toStringz( label );
    this.labelLen = label.length;
    this.description = toStringz( description );
    this.descriptionLen = description.length;
  }
}
private Metric[] sysmetrics;

static this() {
  sysmetrics = [
    Metric( SM_CXSCREEN, "SM_CXSCREEN", "Screen width in pixels" ),
    Metric( SM_CYSCREEN, "SM_CYSCREEN", "Screen height in pixels" ),
    Metric( SM_CXVSCROLL, "SM_CXVSCROLL", "Vertical scroll width" ),
    Metric( SM_CYHSCROLL, "SM_CYHSCROLL", "Horizontal scroll height" ),
    Metric( SM_CYCAPTION, "SM_CYCAPTION", "Caption bar height" ),
    Metric( SM_CXBORDER, "SM_CXBORDER", "Window border width" ),
    Metric( SM_CYBORDER, "SM_CYBORDER", "Window border height" ),
    Metric( SM_CXDLGFRAME, "SM_CXDLGFRAME", "Dialog frame width" ),
    Metric( SM_CYDLGFRAME, "SM_CYDLGFRAME", "Dialog frame height" ),
    Metric( SM_CYVTHUMB, "SM_CYVTHUMB", "Vertical scroll thumb height" ),
    Metric( SM_CXHTHUMB, "SM_CXHTHUMB", "Vertical scroll thumb widht" ),
      /+
            
      SM_CXICON =               11,
      SM_CYICON =               12,
      SM_CXCURSOR =             13,
      SM_CYCURSOR =             14,
      SM_CYMENU =               15,
      SM_CXFULLSCREEN =         16,
      SM_CYFULLSCREEN =         17,
      SM_CYKANJIWINDOW =        18,
      SM_MOUSEPRESENT =         19,
      SM_CYVSCROLL =            20,
      SM_CXHSCROLL =            21,
      SM_DEBUG =                22,
      SM_SWAPBUTTON =           23,
      SM_RESERVED1 =            24,
      SM_RESERVED2 =            25,
      SM_RESERVED3 =            26,
      SM_RESERVED4 =            27,
      SM_CXMIN =                28,
      SM_CYMIN =                29,
      SM_CXSIZE =               30,
      SM_CYSIZE =               31,
      SM_CXFRAME =              32,
      SM_CYFRAME =              33,
      SM_CXMINTRACK =           34,
      SM_CYMINTRACK =           35,
      SM_CXDOUBLECLK =          36,
      SM_CYDOUBLECLK =          37,
      SM_CXICONSPACING =        38,
      SM_CYICONSPACING =        39,
      SM_MENUDROPALIGNMENT =    40,
      SM_PENWINDOWS =           41,
      SM_DBCSENABLED =          42,
      SM_CMOUSEBUTTONS =        43,


      SM_CXFIXEDFRAME =         SM_CXDLGFRAME,
      SM_CYFIXEDFRAME =         SM_CYDLGFRAME,
      SM_CXSIZEFRAME =          SM_CXFRAME,
      SM_CYSIZEFRAME =          SM_CYFRAME,

      SM_SECURE =               44,
      SM_CXEDGE =               45,
      SM_CYEDGE =               46,
      SM_CXMINSPACING =         47,
      SM_CYMINSPACING =         48,
      SM_CXSMICON =             49,
      SM_CYSMICON =             50,
      SM_CYSMCAPTION =          51,
      SM_CXSMSIZE =             52,
      SM_CYSMSIZE =             53,
      SM_CXMENUSIZE =           54,
      SM_CYMENUSIZE =           55,
      SM_ARRANGE =              56,
      SM_CXMINIMIZED =          57,
      SM_CYMINIMIZED =          58,
      SM_CXMAXTRACK =           59,
      SM_CYMAXTRACK =           60,
      SM_CXMAXIMIZED =          61,
      SM_CYMAXIMIZED =          62,
      SM_NETWORK =              63,
      SM_CLEANBOOT =            67,
      SM_CXDRAG =               68,
      SM_CYDRAG =               69,
      SM_SHOWSOUNDS =           70,
      SM_CXMENUCHECK =          71,
      SM_CYMENUCHECK =          72,
      SM_SLOWMACHINE =          73,
      SM_MIDEASTENABLED =       74,
      SM_CMETRICS =             75,
      +/
      Metric( SM_CMETRICS, "SM_CMETRICS", "SYMETRICS?!?!?! LOOOOL" ),  
  ];
}

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClassA( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  HDC hdc;
  PAINTSTRUCT ps; 
  RECT rect;
  TEXTMETRICA tm;
  
  static int cxChar, cxCaps, cyChar; //Average char width, caps width and char height respectively.
  

  switch( message ) {
    case WM_CREATE:
      hdc = GetDC( hwnd );
      scope( exit ) { 
        ReleaseDC( hwnd, hdc );
        PlaySoundA( "boom.wav".toStringz, null, SND_FILENAME | SND_ASYNC );
      }
      GetTextMetricsA( hdc, &tm );
      cxChar = tm.tmAveCharWidth;
      cxCaps = ( tm.tmPitchAndFamily & 1 ? 3 : 2 ) * cxChar / 2;
      cyChar = tm.tmHeight + tm.tmExternalLeading;
      return 0;
    case WM_LBUTTONUP:
    case WM_PAINT:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      scope( exit ){ EndPaint( hwnd, & ps ); }
      int height = 0;
      foreach( metric; sysmetrics ) {
        TextOutA( hdc, 0, height, metric.label, metric.labelLen );
        TextOutA( hdc, 22 * cxCaps, height, metric.description, metric.descriptionLen );
        SetTextAlign( hdc, TA_RIGHT | TA_TOP );
        auto value = GetSystemMetrics( metric.index );
        string valueStr;
        try {
          valueStr = value.to!string;
        } catch( Exception e ) { ; }
        TextOutA( hdc, 22 * cxCaps + 40 * cxChar, height, valueStr.toStringz, valueStr.length );
        SetTextAlign( hdc, TA_LEFT | TA_TOP );
        height += cyChar;
      }
      
      return 0;
    case WM_DESTROY:
      PostQuitMessage( 0 );
      return 0;
    case WM_LBUTTONDOWN:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      GetClientRect( hwnd, &rect );
      DrawTextA( hdc, "WOOOOOOOOOOOOOOOOOOOOOT".toStringz, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER );
      EndPaint( hwnd, &ps );
      return 0;      
    default:
      break;
  }
  return DefWindowProcA( hwnd, message, wParam, lParam );
}

int mainImpl( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow ) {
  auto className = toStringz( "My First M'ofocking Window" );
  WNDCLASS wndClass;
  
  //Window class definition.
  wndClass.style = CS_HREDRAW | CS_VREDRAW;
  wndClass.lpfnWndProc = &WndProc;
  wndClass.cbClsExtra = 0;
  wndClass.cbWndExtra = 0;
  wndClass.hInstance  = hInstance;
  wndClass.hIcon = LoadIconA( null, IDI_EXCLAMATION );
  wndClass.hCursor = LoadCursorA( null, IDC_CROSS );
  wndClass.hbrBackground = GetStockObject( WHITE_BRUSH );
  wndClass.lpszMenuName = null;
  wndClass.lpszClassName = className;
  //Register the class.
  wndClass.register();
  //Then create an instance.
  HWND hWnd;
  hWnd = CreateWindowA(
    className,                        //Window class used.
    "The goddamn program".toStringz,  //Window caption.
    WS_OVERLAPPEDWINDOW,                    //Window style.
    CW_USEDEFAULT,                    //Initial x position.
    CW_USEDEFAULT,                    //Initial y position.
    CW_USEDEFAULT,                    //Initial x size.
    CW_USEDEFAULT,                    //Initial y size.
    null,                             //Parent window handle.
    null,                             //Window menu handle.
    hInstance,                        //Program instance handle.
    null                              //Creation parameters.
  );                           
 

  ShowWindow( hWnd, SW_SHOWMAXIMIZED );
  UpdateWindow( hWnd ); 

  MSG msg;
  while( GetMessageA( &msg, null, 0, 0 ) ) {
    TranslateMessage( &msg );
    DispatchMessageA( &msg );
  }

  return msg.wParam; 
}

extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
  int result;
  void exceptionHandler(Throwable e) { throw e; }

  try {
    Runtime.initialize(&exceptionHandler);
    result = mainImpl(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
    Runtime.terminate(&exceptionHandler);
  } catch( Throwable o ) {
    MessageBoxA( null, o.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION );
    result = 0;
  }

  return result;
}



