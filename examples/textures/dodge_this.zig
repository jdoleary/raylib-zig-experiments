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
const agro_radius = 250;
const unit_size = 16.0;
const heroMaxHealth = 10;

const arena_size = 1000;

const Kind = enum { red, blue, yellow, hero };
const Unit = struct {
    pos: rl.Vector2,
    kind: Kind,
    target: rl.Vector2,
    velocity: rl.Vector2,
};
const NUMBER_OF_ENEMIES = 10;
var enemies: [NUMBER_OF_ENEMIES]Unit = undefined;
fn getRandomPointBetweenBounds() rl.Vector2{
    const xRand = @intToFloat(f32,rl.GetRandomValue(0,100))/100.0;
    const yRand = @intToFloat(f32, rl.GetRandomValue(0,100))/100.0;
    return rl.Vector2{.x= rlm.Lerp(0, arena_size, xRand), .y= rlm.Lerp(0, arena_size, yRand)};
}
fn makeUnit(kind:Kind) Unit {
    const pos = getRandomPointBetweenBounds();
    return Unit {
        .pos = pos,
        .kind = kind,
        .target = pos,
        .velocity = rl.Vector2{.x=0,.y=0}
    };

}

fn moveToTarget(self: *rl.Vector2, target:rl.Vector2, speed: f32) bool {
    var bigA = target.x - self.x;
    var bigB = target.y - self.y;
    var bigC = @sqrt(bigA*bigA + bigB*bigB);
    if(bigC < speed){
        self.x = target.x;
        self.y = target.y;
        return true;
    }
    if(bigC == 0){
        return true;
    }
    var a = speed*bigA/bigC;
    var b = speed*bigB/bigC;
    self.x += a;
    self.y += b;
    // Haven't yet reached target
    return false;
}
fn moveToTargetDynamicSpeed(self: *rl.Vector2, target:rl.Vector2) bool {
    const speed = rlm.Lerp(0.0,20.0, rlm.Vector2Distance(self.*, target)/300.0);
    return moveToTarget(self, target, speed);
}
fn areUnitsColliding(a: *Unit, b: *Unit) bool {
    // 1.8 instead of 2 so that it really looks like they touch before they repel
    return rlm.Vector2Distance(a.pos, b.pos) <= unit_size*1.8;
}
// Reduces velocity per tick
const drag = 0.94;
fn useVelocity(self: *Unit) void {
    self.pos.x += self.velocity.x;
    self.pos.y += self.velocity.y;
    self.velocity.x *= drag;
    self.velocity.y *= drag;
}
fn doArenaBorderCollision(unit: *Unit) void {
    if(unit.pos.x > arena_size){
        unit.pos.x = arena_size;
    }
    if(unit.pos.x < 0){
        unit.pos.x = 0;
    }
    if(unit.pos.y > arena_size){
        unit.pos.y = arena_size;
    }
    if(unit.pos.y < 0){
        unit.pos.y = 0;
    }
}
const bounce_velocity = 6.0;
fn addVelocityAway(forUnit: *Unit, from: rl.Vector2) void{
    const bigA = from.x - forUnit.pos.x;
    const bigB = from.y - forUnit.pos.y;
    const bigC = @sqrt(bigA*bigA + bigB*bigB);
    if(bigC == 0){
        return;
    }
    const a = bigA/bigC;
    const b = bigB/bigC;
    forUnit.velocity.x -= a*bounce_velocity;
    forUnit.velocity.y -= b*bounce_velocity;
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;
    var score:u32 = 0;
    var heroHealth:i32 = heroMaxHealth;

    rl.InitAudioDevice();      // Initialize audio device
    rl.InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim");

    var hero = Unit {
        .pos = rl.Vector2{.x=0,.y=0},
        .kind = Kind.hero,
        .target = rl.Vector2{.x=0,.y=0},
        .velocity = rl.Vector2{.x=0,.y=0}
    };
    var z:usize = 0;
    while(z < NUMBER_OF_ENEMIES): (z+=1){
        if(z < 7){
            enemies[z] = makeUnit(Kind.yellow);
        }else if (z < 9){
            enemies[z] = makeUnit(Kind.blue);
        }else{
            enemies[z] = makeUnit(Kind.red);
        }
    }

    var camera = rl.Camera2D {
        .target = rl.Vector2 { .x = hero.pos.x, .y = hero.pos.y },
        .offset = rl.Vector2 { .x = screenWidth/2, .y = screenHeight/2 },
        .rotation = 0,
        .zoom = 1,
    };

    // Set mouse position so it doens't crash with nan
    rl.SetMousePosition(screenWidth/2,screenHeight/2);

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
            // std.debug.print("mouse: {d:.2} {d:.2}, {d:.2} {d:.2}\n", .{mousePos.x, mousePos.y, mousePosRaw.x, mousePosRaw.y});
            _ = moveToTargetDynamicSpeed(&hero.pos, mousePos);
            _ = moveToTargetDynamicSpeed(&camera.target, hero.pos);

            rl.ClearBackground(rl.RAYWHITE);
            // if (c.GuiButton(.{ .x= 25, .y=255, .width=125, .height=30 }, "test")) {
            //     std.debug.print("Button!\n", .{});
            // }
            // Draw grid
            const grids = arena_size/100;
            for ([_]u32{0} ** (grids + 1)) |_, i| {
                for ([_]u32{0} ** (grids + 1)) |_, j| {
                    rl.DrawCircle(@intCast(c_int,i*100), @intCast(c_int,j*100), 2, rl.BLACK);
                }
            }
            for(enemies) |*enemy| {
                const color = switch(enemy.kind) {
                    Kind.blue => rl.BLUE,
                    Kind.hero => rl.GREEN,
                    Kind.red => rl.RED,
                    Kind.yellow => rl.YELLOW,
                };
                // Enemy behavior
                switch(enemy.kind){
                    Kind.hero => {
                    },
                    Kind.blue => {
                        // Flee
                        if(rlm.Vector2Distance(enemy.pos, hero.pos) < agro_radius){
                            enemy.target = rlm.Vector2Subtract(enemy.pos, rlm.Vector2Subtract(hero.pos, enemy.pos));
                        }
                    },
                    Kind.yellow => {
                    },
                    Kind.red => {
                        // chase 
                        if(rlm.Vector2Distance(enemy.pos, hero.pos) < agro_radius){
                            enemy.target = hero.pos;
                        }
                    },
                }
                const arrivedAtTarget = moveToTarget(&enemy.pos, enemy.target, 2);
                if(arrivedAtTarget){
                    // Pick a new target
                    enemy.target = getRandomPointBetweenBounds();
                }
                if(areUnitsColliding(&hero, enemy)){
                    switch(enemy.kind){
                        Kind.blue => {
                            score+=1;
                            // Respawn
                            enemy.pos = getRandomPointBetweenBounds();
                        },
                        Kind.red => {
                            heroHealth-=1;
                            addVelocityAway(enemy, hero.pos);
                            addVelocityAway(&hero, enemy.*.pos);
                        },
                        Kind.yellow => {
                            heroHealth-=1;
                            addVelocityAway(enemy, hero.pos);
                            addVelocityAway(&hero, enemy.*.pos);
                        },
                        else => {},
                    }
                }
                useVelocity(enemy);
                doArenaBorderCollision(enemy);
                rl.DrawCircle(@floatToInt(c_int, enemy.*.pos.x), @floatToInt(c_int,enemy.*.pos.y), unit_size, color);
            }
            useVelocity(&hero);
            doArenaBorderCollision(&hero);
            rl.DrawCircle(@floatToInt(c_int, hero.pos.x), @floatToInt(c_int,hero.pos.y), unit_size, rl.GREEN);

            camera.End();
            rl.DrawText(rl.TextFormat("Score: %03i", @intCast(c_int, score)), 25, 50, 20, rl.GREEN);
            rl.DrawText(rl.TextFormat("Health: %03i", @intCast(c_int, heroHealth)), 25, 75, 20, rl.RED);
            rl.DrawFPS(25,25);
        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    rl.CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
