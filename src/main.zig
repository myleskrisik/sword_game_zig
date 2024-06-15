const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

const Subpixel = struct {
    const SUBPIXEL_BITS = 4;
    sp: i32 = 0,

    pub fn getPixels(self: Subpixel) i32 {
        return self.sp >> SUBPIXEL_BITS;
    }
};

pub fn main() !void {
    const screen_width = 800;
    const screen_height = 450;

    const virtual_screen_width = 320;
    const virtual_screen_height = 180;

    const virtual_ratio = screen_width / virtual_screen_width;

    rl.InitWindow(screen_width, screen_height, "My Window Name");
    defer rl.CloseWindow();

    var world_space_camera = rl.Camera2D{ .zoom = 1 };

    var screen_space_camera = rl.Camera2D{ .zoom = 1 };

    const target = rl.LoadRenderTexture(virtual_screen_width, virtual_screen_height);
    defer rl.UnloadRenderTexture(target);

    const source_rect = rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(target.texture.width), .height = @floatFromInt(-target.texture.height) };
    const dest_rect = rl.Rectangle{ .x = -virtual_ratio, .y = -virtual_ratio, .width = screen_width + (virtual_ratio * 2), .height = screen_height + (virtual_ratio * 2) };

    const origin = rl.Vector2{ .x = 0, .y = 0 };

    const camera_x: f32 = 0;
    const camera_y: f32 = 0;

    rl.SetTargetFPS(60);

    const player_sprite = rl.LoadTexture("player.png");
    const player_positon = .{ Subpixel{}, Subpixel{} };
    defer rl.UnloadTexture(player_sprite);

    while (!rl.WindowShouldClose()) {
        screen_space_camera.target = rl.Vector2{ .x = camera_x, .y = camera_y };

        world_space_camera.target.x = screen_space_camera.target.x;
        screen_space_camera.target.x -= world_space_camera.target.x;
        screen_space_camera.target.x *= virtual_ratio;

        world_space_camera.target.y = screen_space_camera.target.y;
        screen_space_camera.target.y -= world_space_camera.target.y;
        screen_space_camera.target.y *= virtual_ratio;

        // Draw worldspace
        {
            rl.BeginTextureMode(target);
            defer rl.EndTextureMode();
            rl.ClearBackground(rl.WHITE);
            {
                rl.BeginMode2D(world_space_camera);
                rl.DrawTexture(player_sprite, player_positon[0].getPixels(), player_positon[1].getPixels(), rl.WHITE);
                defer rl.EndMode2D();
            }
        }
        // Draw screenspace
        {
            rl.BeginDrawing();
            defer rl.EndDrawing();
            rl.ClearBackground(rl.RED);
            {
                rl.BeginMode2D(screen_space_camera);
                defer rl.EndMode2D();
                rl.DrawTexturePro(target.texture, source_rect, dest_rect, origin, 0.0, rl.WHITE);
            }
        }
    }
}
