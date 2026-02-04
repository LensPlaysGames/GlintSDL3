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
external SDL_DestroyWindow : void(window : SDL_Window.ptr);

;; https://wiki.libsdl.org/SDL3/SDL_CreateRenderer
external SDL_CreateRenderer : SDL_Renderer.ptr(window : SDL_Window.ptr, name : byte.ptr);
;; https://wiki.libsdl.org/SDL3/SDL_RenderLine
external SDL_RenderLine : bool(
  renderer : SDL_Renderer.ptr,
  x1 : float, y1 : float,
  x2 : float, y2 : float
) discardable;
;; https://wiki.libsdl.org/SDL3/SDL_SetRenderDrawColor
external SDL_SetRenderDrawColor : void(
  renderer : SDL_Renderer.ptr,
  r : u8, g : u8, b : u8, a : u8
);
;; https://wiki.libsdl.org/SDL3/SDL_RenderClear
external SDL_RenderClear : void(renderer : SDL_Renderer.ptr);
;; https://wiki.libsdl.org/SDL3/SDL_RenderPresent
external SDL_RenderPresent : void(renderer : SDL_Renderer.ptr);
;; https://wiki.libsdl.org/SDL3/SDL_DestroyRenderer
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

;; Helper to draw a triangle given three points A, B, and C (three lines
;; AB, BC, AC).
draw_triangle : void(
  renderer : SDL_Renderer.ptr,
  ax : float, ay : float,
  bx : float, by : float,
  cx : float, cy : float,
) {
  ;; LINE AB
  SDL_RenderLine renderer, ax, ay, bx, by;
  ;; LINE AC
  SDL_RenderLine renderer, ax, ay, cx, cy;
  ;; LINE BC
  SDL_RenderLine renderer, bx, by, cx, cy;
};

FPoint2 :: struct {
  x : float;
  y : float;
};

midpoint : FPoint2(
  ax : float, ay : float,
  bx : float, by : float
) {
  out : FPoint2;
  out.x := ax + bx;
  out.y := ay + by;
  out.x /= 2.0;
  out.y /= 2.0;
  out;
};

;; Sierpinski triangle
;;
;; Write helper to draw a triangle given three points, then do it again
;; three more times after adjusting the points like so:
;;   1)
;;     A -- (A + B) / 2
;;     B -- (A + C) / 2
;;     C -- A
;;   2)
;;     A -- B
;;     B -- (B + C) / 2
;;     C -- (A + B) / 2
;;   3)
;;     A -- (B + C) / 2
;;     B -- C
;;     C -- (A + C) / 2
;;
;; Put a max limit on the depth of this occurring, and, voila, fractal.
sierpinski : void(
  renderer : SDL_Renderer.ptr,
  ax : float, ay : float,
  bx : float, by : float,
  cx : float, cy : float,
  steps : uint
) {
  draw_triangle renderer, ax, ay, bx, by, cx, cy;

  steps -= 1;
  if not steps, return;

  mid_ab :: midpoint ax, ay, bx, by;
  mid_ac :: midpoint ax, ay, cx, cy;
  mid_bc :: midpoint bx, by, cx, cy;

  sierpinski renderer, ax, ay, mid_ab.x, mid_ab.y, mid_ac.x, mid_ac.y, steps;
  sierpinski renderer, mid_ab.x, mid_ab.y, bx, by, mid_bc.x, mid_bc.y, steps;
  sierpinski renderer, mid_ac.x, mid_ac.y, mid_bc.x, mid_bc.y, cx, cy, steps;
};

sierpinski_top : void(
  renderer : SDL_Renderer.ptr,
  steps : uint
) {
  sierpinski renderer, 0.0, 480.0, 480.0, 480.0, 240.0, 0.0, steps;
};

x :: 1;
max :: 10;

;; Enter event loop
done :: false;
event : SDL_Event;
while not done, {
  while (SDL_PollEvent &event), {
    if event.type = (u32 SDLEventTypes.QUIT),
      done := true;
  };

  ;; Update active draw color.
  SDL_SetRenderDrawColor renderer, 0, 0, 0, 0xff;
  ;; Draw active color to entire screen.
  SDL_RenderClear renderer;

  SDL_SetRenderDrawColor renderer, 0xff, 0xff, 0xff, 0xff;

  x += 1;
  if x > max,
    x := 1;

  sierpinski_top renderer, x;

  ;; Actually display rendered data.
  SDL_RenderPresent renderer;

  ;; This simple program gets 1000s of FPS unless we do something about it.
  SDL_Delay 125;
};

SDL_DestroyRenderer renderer;
SDL_DestroyWindow window;
SDL_Quit;
