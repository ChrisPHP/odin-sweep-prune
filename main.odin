package  main

import rl "vendor:raylib"
import "core:math/rand"
import "core:fmt"
import "core:sort"

NUM_ENEMIES :: 20
SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080

Enemy :: struct {
    position: [2]f32,
    velocity: [2]f32,
    speed: f32,
    width, height: f32,
    collided: bool
}

TOTAL_CHECKS: int = 0
COLLISIONS: int = 0

enemies: [dynamic]Enemy

spawn_enemies :: proc() {
    for i in 0..<NUM_ENEMIES {
        enemy := Enemy{
            position = [2]f32{
                rand.float32_range(150, SCREEN_WIDTH-150),
                rand.float32_range(150, SCREEN_HEIGHT-150) ,
            },
            velocity = [2]f32{
                rand.float32_range(-4,4),
                rand.float32_range(-4,4)
            },
            width = 100,
            height = 100,
            collided = false
        }
        append(&enemies, enemy)
    }
}

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Sort, Sweep and Prune")
    rl.SetTargetFPS(60)

    spawn_enemies()
    populate_edge_array()

    for !rl.WindowShouldClose() {
        total_checks: int = 0
        collision: int = 0

        deltaTime := rl.GetFrameTime()

        insertion_sort_edges()
        //sort.heap_sort_proc(edges[:], sort_edges)
        sweep_prune()

        for &enemy, index in enemies {
            enemy.position.x += enemy.velocity.x
            enemy.position.y += enemy.velocity.y

            if enemy.position.x >= (SCREEN_WIDTH - enemy.width/2) || enemy.position.x <= enemy.width/2 {
                enemy.velocity.x *= -1
            }
            if enemy.position.y >= (SCREEN_HEIGHT - enemy.height/2) || enemy.position.y <= enemy.height/2 { 
                enemy.velocity.y *= -1
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)


        for enemy in enemies {
            rect := rl.Rectangle{
                x = enemy.position.x,
                y = enemy.position.y,
                width = enemy.width,
                height = enemy.height
            }
            if enemy.collided {
                rl.DrawRectanglePro(rect, rl.Vector2{50, 50}, 0, rl.RED)
            } else {
                rl.DrawRectanglePro(rect, rl.Vector2{50, 50}, 0, rl.BLUE)
            }
        }
        check_string := fmt.ctprintf("Total Checks: %v", TOTAL_CHECKS)
        collision_string := fmt.ctprintf("Collisions: %v", COLLISIONS)
        rl.DrawText(check_string, 25, 25, 20, rl.BLACK)
        rl.DrawText(collision_string, 25, 50, 20, rl.BLACK)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}