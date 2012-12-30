/**
  Experiencing with device capabilities.
*/
module devcaps;

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
  Device capability.
  */
struct Capability {
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
private Capability[] capabilities;

static this() {
  capabilities = [
    Capability( HORZSIZE, "HORZSIZE", "Width in millimeters" ),
    Capability( VERTSIZE, "VERTSIZE", "Height in millimeters" ),
    Capability( HORZRES, "HORZRES", "Width in pixels" ),
    Capability( VERTRES, "VERTRES", "Height in raster lines" ),
    Capability( BITSPIXEL, "BITSPIXEL", "Color bits per pixel" ),
    Capability( PLANES, "PLANES", "Number of color planes" ),
    Capability( NUMBRUSHES, "NUMBRUSHES", "Number of device brushes" ),
    Capability( NUMPENS, "NUMPENS", "Number of device pens" ),
    Capability( NUMMARKERS, "NUMMARKERS", "Number of device markers" ),
    Capability( NUMFONTS, "NUMFONTS", "Number of device fonts" ),
    Capability( NUMCOLORS, "NUMCOLORS", "Number of device colors" ),
    Capability( PDEVICESIZE, "PDEVICESIZE", "Size of device structure" ),
    Capability( ASPECTX, "ASPECTX", "Relative width of pixel" ),
    Capability( ASPECTY, "ASPECTY", "Relative height of pixel" ),
    Capability( ASPECTXY, "ASPECTXY", "Relative diagonal of pixel" ),
    Capability( LOGPIXELSX, "LOGPIXELSX", "Horizontal dots per inch" ),
    Capability( LOGPIXELSY, "LOGPIXELSY", "Vertical dots per inch" ),
    Capability( SIZEPALETTE, "SIZEPALETTE", "Number of palette entries" ),
    Capability( NUMRESERVED, "NUMRESERVED", "Reserved palette entries" ),
    Capability( COLORRES, "COLORRES", "Actual color resolution" )
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
      si.nMax = capabilities.length - 1;
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
      paintEnd = min( capabilities.length - 1, verticalPos + ps.rcPaint.bottom / cyChar );
      
      //Could optimize by clipping the rest too.
      for( size_t i = paintBegin; i <= paintEnd; ++i ) {
        auto cap = capabilities[ i ];
        x = cxChar * ( 1 - horizontalPos );
        y = cyChar * ( i - verticalPos );
        TextOutA( hdc, x, y, cap.label, cap.labelLen );
        TextOutA( hdc,x + ( 22 * cxCaps ), y, cap.description, cap.descriptionLen );
        SetTextAlign( hdc, TA_RIGHT | TA_TOP );
        auto value = GetDeviceCaps( hdc, cap.index );
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



