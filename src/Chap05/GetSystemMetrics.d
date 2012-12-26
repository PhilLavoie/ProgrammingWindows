import std.c.windows.windows;
import std.stdio;

void main( string[] args ) {
  MONITORINFO mInfo; mInfo.cbSize = MONITORINFO.sizeof;
  POINT p; p.x = 0; p.y = 0;
  HMONITOR hm = MonitorFromPoint( p, MONITOR_DEFAULTTOPRIMARY );
  writeln( "Monitor handle: ", hm );
  
  GetMonitorInfoA( hm, &mInfo );
  
  
  writeln( 
    "Monitor info::Monitor rectangle{ left = ", mInfo.rcMonitor.left,
    ", top = ", mInfo.rcMonitor.top,
    ", right = ", mInfo.rcMonitor.right,
    ", bottom = ", mInfo.rcMonitor.bottom,
    " }"
  );
}