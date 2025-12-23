;; Utilizing SDL3 from Glint

;; From SDL3/SDL_Init.h
SDLInitFlags : enum(u32) {
  ;; `SDL_INIT_AUDIO` implies `SDL_INIT_EVENTS`
  AUDIO = 0x00000010,
  ;; `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`, should be initialized on the main thread
  VIDEO = 0x00000020,
  ;; `SDL_INIT_JOYSTICK` implies `SDL_INIT_EVENTS`
  JOYSTICK = 0x00000200,
  ;; `SDL_INIT_GAMEPAD` implies `SDL_INIT_JOYSTICK`
  HAPTIC = 0x00001000,
  GAMEPAD = 0x00002000,
  ;; `SDL_INIT_SENSOR` implies `SDL_INIT_EVENTS`
  EVENTS = 0x00004000,
  SENSOR = 0x00008000,
  ;; `SDL_INIT_CAMERA` implies `SDL_INIT_EVENTS`
  CAMERA = 0x00010000,
};

;; Opaque
SDL_Window : struct {};

SDLWindowFlags : enum(u32) {
  ;; window is in fullscreen mode
  FULLSCREEN           = 0x0000000000000001,
  ;; window usable with OpenGL context
  OPENGL               = 0x0000000000000002,
  ;; window is occluded
  OCCLUDED             = 0x0000000000000004,
  ;; window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible
  HIDDEN               = 0x0000000000000008,
  ;; no window decoration
  BORDERLESS           = 0x0000000000000010,
  ;; window can be resized
  RESIZABLE            = 0x0000000000000020,
  ;; window is minimized
  MINIMIZED            = 0x0000000000000040,
  ;; window is maximized
  MAXIMIZED            = 0x0000000000000080,
  ;; window has grabbed mouse input
  MOUSE_GRABBED        = 0x0000000000000100,
  ;; window has input focus
  INPUT_FOCUS          = 0x0000000000000200,
  ;; window has mouse focus
  MOUSE_FOCUS          = 0x0000000000000400,
  ;; window not created by SDL
  EXTERNAL             = 0x0000000000000800,
  ;; window is modal
  MODAL                = 0x0000000000001000,
  ;; window uses high pixel density back buffer if possible
  HIGH_PIXEL_DENSITY   = 0x0000000000002000,
  ;; window has mouse captured (unrelated to MOUSE_GRABBED)
  MOUSE_CAPTURE        = 0x0000000000004000,
  ;; window has relative mode enabled
  MOUSE_RELATIVE_MODE  = 0x0000000000008000,
  ;; window should always be above others
  ALWAYS_ON_TOP        = 0x0000000000010000,
  ;; window should be treated as a utility window, not showing in the task bar and window list
  UTILITY              = 0x0000000000020000,
  ;; window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window
  TOOLTIP              = 0x0000000000040000,
  ;; window should be treated as a popup menu, requires a parent window
  POPUP_MENU           = 0x0000000000080000,
  ;; window has grabbed keyboard input
  KEYBOARD_GRABBED     = 0x0000000000100000,
  ;; window is in fill-document mode (Emscripten only), since SDL 3.4.0
  FILL_DOCUMENT        = 0x0000000000200000,
  ;; window usable for Vulkan surface
  VULKAN               = 0x0000000010000000,
  ;; window usable for Metal view
  METAL                = 0x0000000020000000,
  ;; window with transparent buffer
  TRANSPARENT          = 0x0000000040000000,
  ;; window should not be focusable
  NOT_FOCUSABLE        = 0x0000000080000000
};

;; afaik, an SDL_Event is 128 bytes that is cast depending on the first
;; four bytes treated as a uint32 to give an event kind.
SDL_Event : union {
  type : u32;
  padding : [byte 128];
};

SDLEventTypes : enum(u32) {
  ;; Unused (do not remove)
  FIRST = 0,
  ;; User-requested quit
  QUIT = 0x100,
};

external SDL_Init : bool(flags : u32);
external SDL_CreateWindow : SDL_Window.ptr(title : byte.ptr, w, h : cint, flags : u32);
external SDL_DestroyWindow : void(window : SDL_Window.ptr);
external SDL_PollEvent : cint(e : SDL_Event.ptr);
external SDL_Quit : void();

if not (SDL_Init SDLInitFlags.VIDEO),
  return 1;

window :: SDL_CreateWindow "GlintUI"[0], 640, 480, SDLWindowFlags.RESIZABLE;
if not window,
  return 1;

;; Enter event loop
done :: false;
event : SDL_Event;
while not done, {
   while (SDL_PollEvent &event), {
     if event.type = (u32 SDLEventTypes.QUIT),
       done := true;
   };
};

SDL_DestroyWindow window;
SDL_Quit;
