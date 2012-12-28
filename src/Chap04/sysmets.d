module sysmets;

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

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
    Metric( SM_CXICON, "SM_CXICON", "Icon width" ),
    Metric( SM_CYICON, "SM_CYICON", "Icon height" ),
    Metric( SM_CXCURSOR, "SM_CXCURSOR", "Cursor width" ),
    Metric( SM_CYCURSOR, "SM_CYCURSOR", "Cursor height" ),
    Metric( SM_CYMENU, "SM_CYMENU", "Menu bar height" ),
    Metric( SM_CXFULLSCREEN, "SM_CXFULLSCREEN", "Full screen client area width" ),
    Metric( SM_CYFULLSCREEN, "SM_CYFULLSCREEN", "Full screen client area height" ),
    Metric( SM_CYKANJIWINDOW, "SM_CYKANJIWINDOW", "Kanji window height" ),
    Metric( SM_MOUSEPRESENT, "SM_MOUSEPRESENT", "Is there a mouse here?" ),
    Metric( SM_CYVSCROLL, "SM_CYVSCROLL", "Vertical scroll arrow height" ),
    Metric( SM_CXHSCROLL, "SM_CXHSCROLL", "Horizontal scroll arrow width" ),
    Metric( SM_DEBUG, "SM_DEBUG", "Is there some debug here?" ),
    Metric( SM_SWAPBUTTON, "SM_SWAPBUTTON", "Are left and right click inverted?" ),
    Metric( SM_CXMIN, "SM_CXMIN", "Minimum window width" ),
    Metric( SM_CXSIZE, "SM_CXSIZE", "Min/Max/Close button width" ),
    Metric( SM_CYSIZE, "SM_CYSIZE", "Min/Max/Close button height" ),
    Metric( SM_CXFRAME, "SM_CXFRAME", "Window sizing frame widht" ),
    Metric( SM_CYFRAME, "SM_CYFRAME", "Window sizing frame height" ),
    Metric( SM_CXMINTRACK, "SM_CXMINTRACK", "Minimum window tracking width" ),
    Metric( SM_CYMINTRACK, "SM_CYMINTRACK", "Minimum window tracking height" ),
    Metric( SM_CXDOUBLECLK, "SM_CXDOUBLECLK", "Double click x tolerance" ),
    Metric( SM_CYDOUBLECLK, "SM_CYDOUBLECLK", "Double click y tolerance" ),
    Metric( SM_CXICONSPACING, "SM_CXICONSPACING", "Horizontal icon spacing" ),
    Metric( SM_CYICONSPACING, "SM_CYICONSPACING", "Vertical icon spacing" ),
    Metric( SM_MENUDROPALIGNMENT, "SM_MENUDROPALIGNMENT", "Left or right menu drop" ),
    Metric( SM_PENWINDOWS, "SM_PENWINDOWS", "Pen etensions installed?" ),
    Metric( SM_DBCSENABLED, "SM_DBCSENABLED", "Double byte char set enabled?" ),
    Metric( SM_CMOUSEBUTTONS, "SM_CMOUSEBUTTONS", "Number of mouse button?" ),
    Metric( SM_SECURE, "SM_SECURE", "Is this shit secured?" ),
    Metric( SM_CXEDGE, "SM_CXEDGE", "Text 3D border width" ),
    Metric( SM_CYEDGE, "SM_CYEDGE", "Text 3D border height" ),
    Metric( SM_CXMINSPACING, "SM_CXMINSPACING", "Minimized window spacing width" ),
    Metric( SM_CYMINSPACING, "SM_CYMINSPACING", "Minimized window spacing height" ),
    Metric( SM_CXSMICON, "SM_CXSMICON", "Small icon width" ),
    Metric( SM_CYSMICON, "SM_CYSMICON", "Small icon height" ),
    Metric( SM_CYSMCAPTION, "SM_CYSMCAPTION", "Small caption height" ),
    Metric( SM_CXSMSIZE, "SM_CXSMSIZE", "Small caption button width" ),
    Metric( SM_CYSMSIZE, "SM_CYSMSIZE", "Small caption button height" ),
    Metric( SM_CXMENUSIZE, "SM_CXMENUSIZE", "Menu bar buton width" ),
    Metric( SM_CYMENUSIZE, "SM_CYMENUSIZE", "Menu bar buton height" ),
    Metric( SM_ARRANGE, "SM_ARRANGE", "How minimzed windows arranged" ),
    Metric( SM_CXMINIMIZED, "SM_CXMINIMIZED", "Minimized window width" ),
    Metric( SM_CYMINIMIZED, "SM_CYMINIMIZED", "Minimized window height" ),
    Metric( SM_CXMAXTRACK, "SM_CXMAXTRACK", "Maximum draggable width" ),
    Metric( SM_CYMAXTRACK, "SM_CYMAXTRACK", "Maximum draggable height" ),
    Metric( SM_CXMAXIMIZED, "SM_CXMAXIMIZED", "Maximized window width" ),
    Metric( SM_CYMAXIMIZED, "SM_CYMAXIMIZED", "Maximized window height" ),
    Metric( SM_NETWORK, "SM_NETWORK", "Hello, Network?" ),
    Metric( SM_CLEANBOOT, "SM_CLEANBOOT", "How system was booted" ),
    Metric( SM_CXDRAG, "SM_CXDRAG", "Avoid drag x tolerance" ),
    Metric( SM_CYDRAG, "SM_CYDRAG", "Avoid drag y tolerance" ),
    Metric( SM_SHOWSOUNDS, "SM_SHOWSOUNDS", "Present sounds visually" ),
    Metric( SM_CXMENUCHECK, "SM_CXMENUCHECK", "Menu check-mark widht" ),
    Metric( SM_CYMENUCHECK, "SM_CYMENUCHECK", "Menu check-mark height" ),
    Metric( SM_SLOWMACHINE, "SM_SLOWMACHINE", "Is this machine worth crap?" ),
    Metric( SM_MIDEASTENABLED, "SM_MIDEASTENABLED", "Speak paki?" ),
    Metric( SM_MOUSEWHEELPRESENT, "SM_MOUSEWHEELPRESENT", "Rolling that wheel, aren't we?" ),
    Metric( SM_XVIRTUALSCREEN, "SM_XVIRTUALSCREEN", "Virtual screen x origin" ),
    Metric( SM_YVIRTUALSCREEN, "SM_YVIRTUALSCREEN", "Virtual screen y origin" ),
    Metric( SM_CXVIRTUALSCREEN, "SM_CXVIRTUALSCREEN", "Virtual screen width" ),
    Metric( SM_CYVIRTUALSCREEN, "SM_CYVIRTUALSCREEN", "Virtual screen height" ),
    Metric( SM_CMONITORS, "SM_CMONITORS", "Number of monitors" ),
    Metric( SM_SAMEDISPLAYFORMAT, "SM_SAMEDISPLAYFORMAT", "Same color format flag" )
  ];
}

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClassA( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static int cxChar, cxCaps, cyChar; //Average char width, caps width and char height respectively.
  static int cxClient, cyClient; //Current window size (width and height).
  static int maxWidth;
  
  HDC hdc;
  PAINTSTRUCT ps; 
  RECT rect;
  TEXTMETRICA tm;
  SCROLLINFO si;
  
  int x, y, verticalPos, horizontalPos, paintBegin, paintEnd;
  
  

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
      maxWidth = 40 * cxChar + 22 * cxCaps; //Save the width of the three columns.
      return 0;
    case WM_SIZE:
      cxClient = LOWORD( lParam );
      cyClient = HIWORD( lParam );
      //Set vertical scroll bar range and page size.
      si.cbSize = si.sizeof;
      si.fMask = SIF_RANGE | SIF_PAGE;
      si.nMin = 0;
      si.nMax = sysmetrics.length - 1;
      si.nPage = cyClient / cyChar; //Number of lines per page.
      SetScrollInfo( hwnd, SB_VERT, &si, true );
      //Set horizontal scroll bar range and page size.
      si.cbSize = si.sizeof;
      si.fMask = SIF_RANGE | SIF_PAGE;
      si.nMin = 0;
      si.nMax = 2 + maxWidth / cxChar;
      si.nPage = cxClient / cxChar; //Number of columns per page.
      SetScrollInfo( hwnd, SB_HORZ, &si, true );
      return 0;
    case WM_VSCROLL:
      //Get all vertical scroll bar info.
      si.cbSize = si.sizeof;
      si.fMask = SIF_ALL;
      GetScrollInfo( hwnd, SB_VERT, &si );
      verticalPos = si.nPos;
      
      switch( LOWORD( wParam ) ) {
        case SB_TOP:
          si.nPos = si.nMin;
          break;
        case SB_BOTTOM:
          si.nPos = si.nMax;
          break;
        case SB_LINEUP:
          --si.nPos;
          break;
        case SB_LINEDOWN:
          ++si.nPos;
          break;
        case SB_PAGEUP:
          si.nPos -= si.nPage;
          break;
        case SB_PAGEDOWN:
          si.nPos += si.nPage;
          break;
        case SB_THUMBTRACK:
          si.nPos = si.nTrackPos;
          break;
        default:
      }
      si.fMask = SIF_POS;
      SetScrollInfo( hwnd, SB_VERT, &si, true );
      GetScrollInfo( hwnd, SB_VERT, &si );
      if( si.nPos != verticalPos ) {
        ScrollWindow( hwnd, 0, cyChar * ( verticalPos - si.nPos ), null, null );
        UpdateWindow( hwnd );
      }
      return 0;
    case WM_HSCROLL:
      //Get all the horizontal scroll bar information.
      si.cbSize = si.sizeof;
      si.fMask = SIF_ALL;
      GetScrollInfo( hwnd, SB_HORZ, &si );
      horizontalPos = si.nPos;
      
      switch( LOWORD( wParam ) ) {
        case SB_LINELEFT:
          --si.nPos;
          break;
        case SB_LINERIGHT:
          ++si.nPos;
          break;
        case SB_PAGELEFT:
          si.nPos -= si.nPage;
          break;
        case SB_PAGERIGHT:
          si.nPos += si.nPage;
          break;
        case SB_THUMBPOSITION:
          si.nPos = si.nTrackPos;
          break;
        default:
      }
      
      si.fMask = SIF_POS;
      SetScrollInfo( hwnd, SB_HORZ, &si, true );
      GetScrollInfo( hwnd, SB_HORZ, &si );
      if( si.nPos != horizontalPos ) {
        ScrollWindow( hwnd, cxChar * ( horizontalPos - si.nPos ), 0, null, null );
        //UpdateWindow( hwnd );
      }
      
      return 0;
    case WM_LBUTTONUP:
      InvalidateRect( hwnd, null, true );
      UpdateWindow( hwnd );
      return 0;
    case WM_PAINT:
      //InvalidateRect( hwnd, null, true ); //Invalidate the whole client area.
      hdc = BeginPaint( hwnd, &ps );
      scope( exit ){ EndPaint( hwnd, & ps ); }
      
      //Get vertical scroll bar pos.
      si.cbSize = si.sizeof;
      si.fMask = SIF_POS;
      GetScrollInfo( hwnd, SB_VERT, &si );
      verticalPos = si.nPos;
      //Get the horizontal pos.
      GetScrollInfo( hwnd, SB_HORZ, &si );
      horizontalPos = si.nPos;
      //Determine limits.
      paintBegin = max( 0, verticalPos + ps.rcPaint.top / cyChar );
      paintEnd = min( sysmetrics.length - 1, verticalPos + ps.rcPaint.bottom / cyChar );
      
      //Could optimize by clipping the rest too.
      for( size_t i = paintBegin; i <= paintEnd; ++i ) {
        auto metric = sysmetrics[ i ];
        x = cxChar * ( 1 - horizontalPos );
        y = cyChar * ( i - verticalPos );
        TextOutA( hdc, x, y, metric.label, metric.labelLen );
        TextOutA( hdc,x + ( 22 * cxCaps ), y, metric.description, metric.descriptionLen );
        SetTextAlign( hdc, TA_RIGHT | TA_TOP );
        auto value = GetSystemMetrics( metric.index );
        string valueStr;
        try {
          valueStr = value.to!string;
        } catch( Exception e ) { ; }
        TextOutA( hdc, x + ( 22 * cxCaps ) + ( 40 * cxChar ), y, valueStr.toStringz, valueStr.length );
        SetTextAlign( hdc, TA_LEFT | TA_TOP );
      }
      
      return 0;
    case WM_LBUTTONDOWN:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      GetClientRect( hwnd, &rect );
      DrawTextA( hdc, "WOOOOOOOOOOOOOOOOOOOOOT".toStringz, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER );
      EndPaint( hwnd, &ps );
      return 0;
    case WM_DESTROY:
      PostQuitMessage( 0 );
      return 0;    
    default:
      return DefWindowProcA( hwnd, message, wParam, lParam );
  }
  assert( false );
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
    WS_OVERLAPPEDWINDOW | WS_VSCROLL |WS_HSCROLL,                    //Window style.
    CW_USEDEFAULT,                    //Initial x position.
    CW_USEDEFAULT,                    //Initial y position.
    CW_USEDEFAULT,                    //Initial x size.
    CW_USEDEFAULT,                    //Initial y size.
    null,                             //Parent window handle.
    null,                             //Window menu handle.
    hInstance,                        //Program instance handle.
    null                              //Creation parameters.
  );                           
 

  ShowWindow( hWnd, SW_SHOWNORMAL );
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



