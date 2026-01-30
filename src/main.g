;; Utilizing SDL3 from Glint

;; From SDL3/SDL_Init.h
SDLInitFlags :: enum(u32) {
  ;; `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`, should be initialized on
  ;; the main thread
  VIDEO = 0x00000020,
};

;; Opaque
SDL_Window :: struct {};
SDL_Renderer :: struct {};

SDLWindowFlags :: enum(u32) {
  ;; window can be resized
  RESIZABLE = 0x0000000000000020,
};

;; afaik, an SDL_Event is 128 bytes that is cast depending on the first
;; four bytes treated as a uint32 to give an event kind.
SDL_Event :: union {
  type : u32;
  padding : [byte 128];
};

SDLEventTypes :: enum(u32) {
  ;; Unused (do not remove)
  FIRST = 0,
  ;; User-requested quit
  QUIT = 0x100,
};

external SDL_Init : bool(flags : u32);
external SDL_CreateWindow : SDL_Window.ptr(title : byte.ptr, w, h : cint, flags : u32);
external SDL_CreateRenderer : SDL_Renderer.ptr(window : SDL_Window.ptr, name : byte.ptr);
external SDL_DestroyWindow : void(window : SDL_Window.ptr);
external SDL_SetRenderDrawColor : void(
  renderer : SDL_Renderer.ptr,
  r : u8, g : u8, b : u8, a : u8
);
external SDL_RenderClear : void(renderer : SDL_Renderer.ptr);
external SDL_RenderPresent : void(renderer : SDL_Renderer.ptr);
external SDL_DestroyRenderer : void(renderer : SDL_Renderer.ptr);
external SDL_PollEvent : cint(e : SDL_Event.ptr);
external SDL_Delay : void(ms : u32);
external SDL_Quit : void();

print "Beginning GUI Creation...";

if not (SDL_Init SDLInitFlags.VIDEO),
  return 1;

print "SDL Initialized...";

window :: SDL_CreateWindow "GlintUI"[0], 640, 480, SDLWindowFlags.RESIZABLE;
if not window, {
  print "Failed to create window";
  return 1;
};

print "SDL Window Created...";

renderer :: SDL_CreateRenderer window, (byte.ptr 0);
if not renderer, {
  print "Failed to create renderer";
  return 1;
};

print "SDL Renderer Created...";

print "GUI Creation: Success! Entering event loop...";

;; TODO: Sierpinski triangle
;; Need https://wiki.libsdl.org/SDL3/SDL_RenderLine
;;
;; Write helper to draw a triangle given three points A, B, and C (three
;; lines AB, BC, AC).
;;
;; Write helper to draw a triangle given three points, then do it again
;; three more times after adjusting the points like so:
;;   1)
;;     A -- A
;;     B -- (A + B) / 2
;;     C -- (A + C) / 2
;;   2)
;;     A -- (A + B) / 2
;;     B -- B
;;     C -- (B + C) / 2
;;   3)
;;     A -- (A + C) / 2
;;     B -- (B + C) / 2
;;     C -- C
;;
;; Put a max limit on the depth of this occurring, and, voila, fractal.

;; Enter event loop
done :: false;
event : SDL_Event;
color : u8;
while not done, {
  while (SDL_PollEvent &event), {
    if event.type = (u32 SDLEventTypes.QUIT),
      done := true;
  };

  ;; Update active draw color.
  SDL_SetRenderDrawColor renderer, 0, 0, color, 0xff;
  ;; Draw active color to entire screen.
  SDL_RenderClear renderer;
  ;; Actually display rendered data.
  SDL_RenderPresent renderer;

  ;; Change active draw color for next frame.
  color += 1;

  ;; This simple program gets 1000s of FPS unless we do something about it.
  SDL_Delay 10;
};

SDL_DestroyRenderer renderer;
SDL_DestroyWindow window;
SDL_Quit;
