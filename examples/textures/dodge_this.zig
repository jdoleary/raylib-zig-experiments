// Port of https://github.com/raysan5/raylib/blob/master/examples/textures/textures_sprite_anim.c to zig

const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raylib-math");
const c = @cImport({
    @cInclude("my_header.h");
    @cInclude("raylib.h");
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

const MAX_FRAME_SPEED = 15;
const MIN_FRAME_SPEED = 1;
const agro_radius = 300;
var unit_size = 50.0;
var score = 0;
const heroMaxHealth = 10;
var heroHealth = heroMaxHealth;

const arena_size = 1000;

const Kind = enum { red, blue, yellow, hero };
const Unit = struct {
    pos: rl.Vector2,
    kind: Kind,
    target: rl.Vector2,
    velocity: rl.Vector2,
};

fn moveToTargetDynamicSpeed(self: *rl.Vector2, target:rl.Vector2) bool {
    const speed = rlm.Lerp(0.0,20.0, rlm.Vector2Distance(self.*, target)/300.0);
    var bigA = target.x - self.x;
    var bigB = target.y - self.y;
    var bigC = @sqrt(bigA*bigA + bigB*bigB);
    if(bigC < speed){
        return true;
    }
    var a = speed*bigA/bigC;
    var b = speed*bigB/bigC;
    self.x += a;
    self.y += b;
    // Haven't yet reached target
    return false;
}


pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitAudioDevice();      // Initialize audio device
    rl.InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim");

    var hero = Unit {
        .pos = rl.Vector2{.x=0,.y=0},
        .kind = Kind.hero,
        .target = rl.Vector2{.x=0,.y=0},
        .velocity = rl.Vector2{.x=0,.y=0}
    };
    var camera = rl.Camera2D {
        .target = rl.Vector2 { .x = hero.pos.x, .y = hero.pos.y },
        .offset = rl.Vector2 { .x = screenWidth/2, .y = screenHeight/2 },
        .rotation = 0,
        .zoom = 1,
    };

    rl.SetMousePosition(0,0);

    rl.SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.WindowShouldClose())   // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Control frames speed
        // if (rl.IsKeyPressed(rl.KeyboardKey.KEY_RIGHT)) {framesSpeed+=1;}
        // else if (rl.IsKeyPressed(rl.KeyboardKey.KEY_LEFT)) {framesSpeed-=1;}

        // if (framesSpeed > MAX_FRAME_SPEED) {framesSpeed = MAX_FRAME_SPEED;}
        // else if (framesSpeed < MIN_FRAME_SPEED) {framesSpeed = MIN_FRAME_SPEED;}


        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();
            camera.Begin();
        const mousePosRaw = rl.GetMousePosition();
        var mousePos = rl.GetScreenToWorld2D(mousePosRaw, camera);
        std.debug.print("mouse: {d:.2} {d:.2}, {d:.2} {d:.2}\n", .{mousePos.x, mousePos.y, mousePosRaw.x, mousePosRaw.y});
        _ = moveToTargetDynamicSpeed(&hero.pos, mousePos);
        _ = moveToTargetDynamicSpeed(&camera.target, hero.pos);

            rl.ClearBackground(rl.RAYWHITE);
            if (c.GuiButton(.{ .x= 25, .y=255, .width=125, .height=30 }, "test")) {
                std.debug.print("Button!\n", .{});
            }
            // origin
            rl.DrawCircle(0, 0, 2, rl.BLACK);
        std.debug.print("mouse: {d},{d}\n", .{hero.pos.x, hero.pos.y});
            rl.DrawCircle(@floatToInt(c_int, hero.pos.x), @floatToInt(c_int,hero.pos.y), 16, rl.GREEN);
            camera.End();
        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    rl.CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
