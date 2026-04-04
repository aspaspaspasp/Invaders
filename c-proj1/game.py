import math
import os
import sys
import random
import pygame

# ── Constants ────────────────────────────────────────────────────────────────
WIDTH, HEIGHT = 480, 640
FPS  = 60
TITLE = "Claude Invaders"

BLACK     = (  0,   0,   0)
WHITE     = (255, 255, 255)
YELLOW    = (255, 255,   0)
RED       = (220,  30,  30)
CYAN      = (  0, 220, 220)
DARK_BLUE = (  5,   5,  30)

ASSETS_DIR          = os.path.join(os.path.dirname(__file__), "Assets", "spritesheets")
ANIM_RATE           = 5    # game frames per sprite frame
WAVE_INTRO_DURATION = 60   # 1 second at 60 fps


# ── Wave names ────────────────────────────────────────────────────────────────
WAVE_NAMES = [
    "THE VANGUARD",    # 1
    "TWIN TOWERS",     # 2
    "THE ARMADA",      # 3
    "THE DIAMOND",     # 4
    "THREE COLUMNS",   # 5
    "THE WINGS",       # 6
    "THE CROSS",       # 7
    "THE SWARM",       # 8
    "THE PHALANX",     # 9
    "THE GAUNTLET",    # 10
]


# ── Wave definitions ──────────────────────────────────────────────────────────
# movement keys:
#   A — locked formation (rigid block drift, original width preserved)
#   B — sine oscillation (fixed amplitude, no wall bounce)
#   C — individual patrol zones (each enemy bounces in its own ±range)
#   D — descending pressure (straight down, accelerates as enemies die)
#   E — hybrid (A until 50% dead, then C)

WAVE_CONFIGS = [
    # ── 1: THE VANGUARD ── C (individual patrol) ── 15 × e_sml ──────────────
    {
        "movement": "C",
        "enemies": [
            (240,  90, "e_sml"),
            (185, 145, "e_sml"), (295, 145, "e_sml"),
            (130, 200, "e_sml"), (240, 200, "e_sml"), (350, 200, "e_sml"),
            ( 75, 255, "e_sml"), (185, 255, "e_sml"), (295, 255, "e_sml"), (405, 255, "e_sml"),
            ( 75, 310, "e_sml"), (185, 310, "e_sml"), (240, 310, "e_sml"), (295, 310, "e_sml"), (405, 310, "e_sml"),
        ],
        "h_speed": 1.0, "patrol_range": 55,
        "shoot_interval": 90, "entry_stagger": 8,
    },
    # ── 2: TWIN TOWERS ── C (individual patrol) ── 17 × e_med/e_sml ─────────
    {
        "movement": "C",
        "enemies": [
            # outer columns e_med (5 each)
            ( 90,  90, "e_med"), ( 90, 145, "e_med"), ( 90, 200, "e_med"), ( 90, 255, "e_med"), ( 90, 310, "e_med"),
            (390,  90, "e_med"), (390, 145, "e_med"), (390, 200, "e_med"), (390, 255, "e_med"), (390, 310, "e_med"),
            # centre row e_sml (3)
            (185, 170, "e_sml"), (240, 170, "e_sml"), (295, 170, "e_sml"),
            # inner flankers e_sml (4)
            (155, 130, "e_sml"), (325, 130, "e_sml"),
            (155, 215, "e_sml"), (325, 215, "e_sml"),
        ],
        "h_speed": 1.2, "patrol_range": 50,
        "shoot_interval": 70, "entry_stagger": 6,
    },
    # ── 3: THE ARMADA ── B (sine oscillation) ── 30 × all types ─────────────
    {
        "movement": "B",
        "enemies": [
            # row 1: e_big (7)
            ( 60,  80, "e_big"), (120,  80, "e_big"), (180,  80, "e_big"),
            (240,  80, "e_big"), (300,  80, "e_big"), (360,  80, "e_big"), (420,  80, "e_big"),
            # row 2: e_med (7)
            ( 60, 135, "e_med"), (120, 135, "e_med"), (180, 135, "e_med"),
            (240, 135, "e_med"), (300, 135, "e_med"), (360, 135, "e_med"), (420, 135, "e_med"),
            # row 3: e_sml (7)
            ( 60, 190, "e_sml"), (120, 190, "e_sml"), (180, 190, "e_sml"),
            (240, 190, "e_sml"), (300, 190, "e_sml"), (360, 190, "e_sml"), (420, 190, "e_sml"),
            # row 4: e_med (5)
            ( 90, 245, "e_med"), (165, 245, "e_med"), (240, 245, "e_med"), (315, 245, "e_med"), (390, 245, "e_med"),
            # row 5: e_sml (4)
            (120, 300, "e_sml"), (210, 300, "e_sml"), (270, 300, "e_sml"), (360, 300, "e_sml"),
        ],
        "h_speed": 0.0,  # unused by B
        "sine_amplitude": 35, "sine_frequency": 0.015,
        "shoot_interval": 50, "entry_stagger": 4,
    },
    # ── 4: THE DIAMOND ── D (descending) ── 21 × e_big/e_med/e_sml ──────────
    {
        "movement": "D",
        "enemies": [
            # inner diamond: e_big at cardinals, e_med filling
            (240,  70, "e_big"),
            (160, 120, "e_med"), (240, 120, "e_med"), (320, 120, "e_med"),
            ( 80, 175, "e_big"), (160, 175, "e_med"), (240, 175, "e_med"), (320, 175, "e_med"), (400, 175, "e_big"),
            (160, 230, "e_med"), (240, 230, "e_med"), (320, 230, "e_med"),
            (240, 285, "e_big"),
            # outer ring: e_sml (8)
            (240,  35, "e_sml"),
            (120,  90, "e_sml"), (360,  90, "e_sml"),
            ( 40, 175, "e_sml"), (440, 175, "e_sml"),
            (120, 260, "e_sml"), (360, 260, "e_sml"),
            (240, 320, "e_sml"),
        ],
        "h_speed": 0.0,  # unused by D
        "descent_speed": 0.3,
        "shoot_interval": 80, "entry_stagger": 7,
    },
    # ── 5: THREE COLUMNS ── D (descending) ── 27 × e_sml/e_med ──────────────
    {
        "movement": "D",
        "enemies": [
            # interleaved: left(e_sml x=100), centre(e_med x=240), right(e_sml x=380)
            (100,  60, "e_sml"), (240,  60, "e_med"), (380,  60, "e_sml"),
            (100,  90, "e_sml"), (240,  90, "e_med"), (380,  90, "e_sml"),
            (100, 120, "e_sml"), (240, 120, "e_med"), (380, 120, "e_sml"),
            (100, 150, "e_sml"), (240, 150, "e_med"), (380, 150, "e_sml"),
            (100, 180, "e_sml"), (240, 180, "e_med"), (380, 180, "e_sml"),
            (100, 210, "e_sml"), (240, 210, "e_med"), (380, 210, "e_sml"),
            (100, 240, "e_sml"), (240, 240, "e_med"), (380, 240, "e_sml"),
            (100, 270, "e_sml"), (240, 270, "e_med"), (380, 270, "e_sml"),
            (100, 300, "e_sml"), (240, 300, "e_med"), (380, 300, "e_sml"),
        ],
        "h_speed": 0.0,
        "descent_speed": 0.35,
        "shoot_interval": 70, "entry_stagger": 5,
    },
    # ── 6: THE WINGS ── D (descending) ── 24 × e_big/e_med/e_sml ────────────
    {
        "movement": "D",
        "enemies": [
            # left wing e_big (5, zigzag)
            ( 45,  85, "e_big"), ( 90, 125, "e_big"), ( 45, 165, "e_big"), ( 90, 205, "e_big"), ( 45, 245, "e_big"),
            # right wing e_big (5, mirror)
            (435,  85, "e_big"), (390, 125, "e_big"), (435, 165, "e_big"), (390, 205, "e_big"), (435, 245, "e_big"),
            # centre spine e_med (6)
            (240,  65, "e_med"), (240, 110, "e_med"), (240, 155, "e_med"),
            (240, 200, "e_med"), (240, 245, "e_med"), (240, 290, "e_med"),
            # inner connectors e_sml (8)
            (155, 100, "e_sml"), (325, 100, "e_sml"),
            (155, 170, "e_sml"), (325, 170, "e_sml"),
            (155, 240, "e_sml"), (325, 240, "e_sml"),
            (155, 310, "e_sml"), (325, 310, "e_sml"),
        ],
        "h_speed": 0.0,
        "descent_speed": 0.4,
        "shoot_interval": 65, "entry_stagger": 6,
    },
    # ── 7: THE CROSS ── A (locked formation) ── 25 × e_big/e_med/e_sml ──────
    {
        "movement": "A",
        "enemies": [
            # top tip
            (240,  55, "e_big"),
            # upper vertical arm (3-wide)
            (210, 100, "e_sml"), (240, 100, "e_sml"), (270, 100, "e_sml"),
            (210, 130, "e_sml"), (240, 130, "e_sml"), (270, 130, "e_sml"),
            # horizontal bar row 1 (e_med, 7)
            ( 60, 158, "e_med"), (120, 158, "e_med"), (180, 158, "e_med"), (240, 158, "e_med"),
            (300, 158, "e_med"), (360, 158, "e_med"), (420, 158, "e_med"),
            # horizontal bar row 2 (e_med, 7)
            ( 60, 192, "e_med"), (120, 192, "e_med"), (180, 192, "e_med"), (240, 192, "e_med"),
            (300, 192, "e_med"), (360, 192, "e_med"), (420, 192, "e_med"),
            # lower vertical arm
            (210, 225, "e_sml"), (240, 225, "e_sml"), (270, 225, "e_sml"),
            (240, 260, "e_sml"),
        ],
        "h_speed": 0.8, "step_down": 14,
        "shoot_interval": 60, "entry_stagger": 5,
    },
    # ── 8: THE SWARM ── A (locked formation) ── 30 × e_sml ──────────────────
    {
        "movement": "A",
        "enemies": [
            # left cluster
            ( 65,  75, "e_sml"), (100,  95, "e_sml"), ( 75, 120, "e_sml"), (110, 140, "e_sml"), ( 60, 165, "e_sml"),
            ( 95, 185, "e_sml"), ( 80, 210, "e_sml"), (115, 225, "e_sml"), ( 65, 250, "e_sml"), (100, 265, "e_sml"),
            # centre cluster
            (210,  65, "e_sml"), (245,  80, "e_sml"), (220, 105, "e_sml"), (255, 125, "e_sml"), (205, 150, "e_sml"),
            (250, 165, "e_sml"), (215, 190, "e_sml"), (255, 205, "e_sml"), (210, 230, "e_sml"), (250, 245, "e_sml"),
            # right cluster
            (365,  75, "e_sml"), (400,  95, "e_sml"), (375, 120, "e_sml"), (410, 140, "e_sml"), (360, 165, "e_sml"),
            (395, 185, "e_sml"), (380, 210, "e_sml"), (415, 225, "e_sml"), (365, 250, "e_sml"), (400, 265, "e_sml"),
        ],
        "h_speed": 0.9, "step_down": 1.5,
        "shoot_interval": 55, "entry_stagger": 4,
    },
    # ── 9: THE PHALANX ── D (descending) ── 30 × e_big/e_med/e_sml ──────────
    {
        "movement": "D",
        "enemies": [
            # 5 rows of 6, alternating type, spacing x=72
            ( 45,  65, "e_big"), (117,  65, "e_big"), (189,  65, "e_big"), (261,  65, "e_big"), (333,  65, "e_big"), (405,  65, "e_big"),
            ( 45, 115, "e_med"), (117, 115, "e_med"), (189, 115, "e_med"), (261, 115, "e_med"), (333, 115, "e_med"), (405, 115, "e_med"),
            ( 45, 165, "e_big"), (117, 165, "e_big"), (189, 165, "e_big"), (261, 165, "e_big"), (333, 165, "e_big"), (405, 165, "e_big"),
            ( 45, 215, "e_med"), (117, 215, "e_med"), (189, 215, "e_med"), (261, 215, "e_med"), (333, 215, "e_med"), (405, 215, "e_med"),
            ( 45, 265, "e_sml"), (117, 265, "e_sml"), (189, 265, "e_sml"), (261, 265, "e_sml"), (333, 265, "e_sml"), (405, 265, "e_sml"),
        ],
        "h_speed": 0.0,
        "descent_speed": 0.5,
        "shoot_interval": 50, "entry_stagger": 4,
    },
    # ── 10: THE GAUNTLET ── B (sine oscillation) ── 47 × all types ───────────
    {
        "movement": "B",
        "enemies": [
            # 6 full rows of 7 + 1 shorter row
            ( 60,  65, "e_big"), (120,  65, "e_big"), (180,  65, "e_big"), (240,  65, "e_big"), (300,  65, "e_big"), (360,  65, "e_big"), (420,  65, "e_big"),
            ( 60, 108, "e_med"), (120, 108, "e_med"), (180, 108, "e_med"), (240, 108, "e_med"), (300, 108, "e_med"), (360, 108, "e_med"), (420, 108, "e_med"),
            ( 60, 151, "e_sml"), (120, 151, "e_sml"), (180, 151, "e_sml"), (240, 151, "e_sml"), (300, 151, "e_sml"), (360, 151, "e_sml"), (420, 151, "e_sml"),
            ( 60, 194, "e_big"), (120, 194, "e_big"), (180, 194, "e_big"), (240, 194, "e_big"), (300, 194, "e_big"), (360, 194, "e_big"), (420, 194, "e_big"),
            ( 60, 237, "e_med"), (120, 237, "e_med"), (180, 237, "e_med"), (240, 237, "e_med"), (300, 237, "e_med"), (360, 237, "e_med"), (420, 237, "e_med"),
            ( 60, 280, "e_sml"), (120, 280, "e_sml"), (180, 280, "e_sml"), (240, 280, "e_sml"), (300, 280, "e_sml"), (360, 280, "e_sml"), (420, 280, "e_sml"),
            # final row: e_big (5, centred)
            ( 90, 323, "e_big"), (165, 323, "e_big"), (240, 323, "e_big"), (315, 323, "e_big"), (390, 323, "e_big"),
        ],
        "h_speed": 0.0,
        "sine_amplitude": 28, "sine_frequency": 0.018,
        "shoot_interval": 40, "entry_stagger": 3, "entry_speed": 2.7,
    },
]


# ── Sprite sheet helper ───────────────────────────────────────────────────────
class SpriteSheet:
    def __init__(self, path, frame_w, frame_h, scale=1):
        raw = pygame.image.load(path).convert_alpha()
        w, h = raw.get_size()
        self.cols   = w // frame_w
        self.rows   = h // frame_h
        self.fw     = round(frame_w * scale)
        self.fh     = round(frame_h * scale)
        self.frames = []
        for r in range(self.rows):
            for c in range(self.cols):
                surf = raw.subsurface(
                    pygame.Rect(c * frame_w, r * frame_h, frame_w, frame_h))
                if scale != 1:
                    surf = pygame.transform.scale(surf, (self.fw, self.fh))
                self.frames.append(surf)

    def get(self, idx):
        return self.frames[idx % len(self.frames)]


def load_sprites():
    def p(name):
        return os.path.join(ASSETS_DIR, name)
    return {
        "ship":   SpriteSheet(p("ship.png"),          16, 24, scale=2.2),
        "e_big":  SpriteSheet(p("enemy-big.png"),     32, 32, scale=1),
        "e_med":  SpriteSheet(p("enemy-medium.png"),  16, 16, scale=2),
        "e_sml":  SpriteSheet(p("enemy-small.png"),   16, 16, scale=2),
        "bolt":   SpriteSheet(p("laser-bolts.png"),   16, 16, scale=1),
        "expl":   SpriteSheet(p("explosion.png"),     16, 16, scale=3),
        "heart":  SpriteSheet(p("power-up.png"),       16, 16, scale=2),
        "boss":   SpriteSheet(p("enemy-big.png"),     32, 32, scale=3),
    }


# ── Player ────────────────────────────────────────────────────────────────────
class Player:
    WIDTH  = 32
    HEIGHT = 32

    SHIP_FRAMES    = {"default": [2, 7], "left": [0, 5], "right": [4, 9]}
    SPEED          = 4
    SHOOT_COOLDOWN = 3
    def __init__(self, sprites):
        self.x             = WIDTH // 2
        self.y             = HEIGHT - 60
        self.lives         = 3
        self.invincible    = 0
        self.facing        = "default"
        self.tick          = 0
        self.frame_idx     = 0
        self.sprites       = sprites
        self.hit_explosion = None
        self.cooldown      = 0
        self.salvo_charge   = 0     # frames SPACE held (60 = fire)
        self.salvo_cooldown = 0
        self.salvo_queue    = []    # [(frames_delay, [(vx,vy),...]), ...]
        self.vel_x         = 0.0
        self.vel_y         = 0.0

    def update(self, keys, fire_pressed=None):
        """Move, fire (Z/X), animate. Returns list of Bullet objects fired this frame."""
        bullets = []

        exploding = self.hit_explosion and not self.hit_explosion.done

        # ── movement with inertia ─────────────────────────────────────────────
        max_spd     = self.SPEED
        accel       = max_spd * 0.12         # reach full speed in ~8 frames
        friction    = 0.86 if exploding else 0.92

        if exploding:
            self.vel_x *= friction
            self.vel_y *= friction
            self.facing = "default"
        else:
            cap = max_spd

            # horizontal
            if keys[pygame.K_LEFT]:
                self.vel_x = max(self.vel_x - accel, -cap)
                self.facing = "left"
            elif keys[pygame.K_RIGHT]:
                self.vel_x = min(self.vel_x + accel,  cap)
                self.facing = "right"
            else:
                self.vel_x *= friction
                self.facing = "default"
            self.vel_x = max(-cap, min(cap, self.vel_x))

            # vertical
            if keys[pygame.K_UP]:
                self.vel_y = max(self.vel_y - accel, -cap)
            elif keys[pygame.K_DOWN]:
                self.vel_y = min(self.vel_y + accel,  cap)
            else:
                self.vel_y *= friction
            self.vel_y = max(-cap, min(cap, self.vel_y))

        # snap tiny velocities to zero to avoid endless micro-drift
        if abs(self.vel_x) < 0.3: self.vel_x = 0.0
        if abs(self.vel_y) < 0.3: self.vel_y = 0.0

        # apply velocity with boundary clamping
        nx = self.x + self.vel_x
        if nx - self.WIDTH // 2 < 0:
            nx = self.WIDTH // 2;  self.vel_x = 0.0
        elif nx + self.WIDTH // 2 > WIDTH:
            nx = WIDTH - self.WIDTH // 2;  self.vel_x = 0.0
        self.x = nx

        ny = self.y + self.vel_y
        if ny - self.HEIGHT // 2 < 0:
            ny = self.HEIGHT // 2;  self.vel_y = 0.0
        elif ny + self.HEIGHT // 2 > HEIGHT:
            ny = HEIGHT - self.HEIGHT // 2;  self.vel_y = 0.0
        self.y = ny

        # ── manual fire (Z or X, suppressed while exploding) ─────────────────────
        if self.cooldown > 0:
            self.cooldown -= 1
        if self.salvo_cooldown > 0:
            self.salvo_cooldown -= 1

        # ── process queued salvo bursts ───────────────────────────────────────
        new_queue = []
        for (t, burst) in self.salvo_queue:
            if t <= 0:
                for vx, vy in burst:
                    bullets.append(Bullet(self.x, self.y - 20, vy, "player",
                                          self.sprites, vx=vx))
            else:
                new_queue.append((t - 1, burst))
        self.salvo_queue = new_queue

        if not exploding:
            both_held = keys[pygame.K_SPACE]
            if both_held:
                self.salvo_charge += 1
                if self.salvo_charge >= 60 and self.salvo_cooldown == 0:
                    self.salvo_charge   = 0
                    self.salvo_cooldown = 45
                    spd = 8
                    angles = [-50 + i * (100 / 7) for i in range(8)]
                    burst = [(math.sin(math.radians(a)) * spd,
                              -math.cos(math.radians(a)) * spd) for a in angles]
                    for delay in (0, 4, 8):
                        self.salvo_queue.append((delay, burst))
            else:
                self.salvo_charge = 0
                if fire_pressed is not None and self.cooldown == 0:
                    self.cooldown = self.SHOOT_COOLDOWN
                    ox = -11 if fire_pressed == pygame.K_z else 11
                    bullets.append(Bullet(self.x + ox, self.y - 20, -8, "player", self.sprites))

        # ── hit explosion ─────────────────────────────────────────────────────
        if self.hit_explosion and not self.hit_explosion.done:
            self.hit_explosion.update()
        elif self.hit_explosion and self.hit_explosion.done:
            self.hit_explosion = None

        if self.invincible > 0: self.invincible -= 1
        self.tick += 1
        if self.tick >= ANIM_RATE:
            self.tick = 0
            self.frame_idx = (self.frame_idx + 1) % 2

        return bullets

    def animate(self):
        """Advance the idle animation without processing movement."""
        self.facing = "default"
        self.tick += 1
        if self.tick >= ANIM_RATE:
            self.tick = 0
            self.frame_idx = (self.frame_idx + 1) % 2

    def hit(self):
        if self.invincible == 0:
            self.lives -= 1
            self.invincible    = 90
            self.hit_explosion = Explosion(self.x, self.y, self.sprites)
            self.salvo_charge  = 0
            self.salvo_queue   = []
            return True
        return False

    def rect(self):
        return pygame.Rect(self.x - 10, self.y - 10, 20, 20)

    def draw(self, surface):
        # while explosion plays, draw it instead of the ship
        if self.hit_explosion and not self.hit_explosion.done:
            self.hit_explosion.draw(surface)
            return
        if self.invincible > 0 and (self.invincible // 6) % 2 == 0:
            return
        idx   = self.SHIP_FRAMES[self.facing][self.frame_idx]
        frame = self.sprites["ship"].get(idx)
        fw, fh = frame.get_size()
        surface.blit(frame, (self.x - fw // 2, self.y - fh // 2))
        if self.salvo_charge >= 6:
            bar_w   = 44
            bar_h   = 4
            fill_w  = int(bar_w * min(self.salvo_charge - 6, 54) / 54)
            bx      = int(self.x) - bar_w // 2
            by      = int(self.y) + self.sprites["ship"].fh // 2 + 4
            pygame.draw.rect(surface, (60, 60, 60),     (bx, by, bar_w, bar_h))
            pygame.draw.rect(surface, (255, 200, 0),    (bx, by, fill_w, bar_h))
            pygame.draw.rect(surface, (255, 240, 120),  (bx, by, bar_w, bar_h), 1)


# ── Bullet ────────────────────────────────────────────────────────────────────
class Bullet:
    FRAMES = {"player": [2, 3], "enemy": [0, 1]}

    def __init__(self, x, y, vy, kind, sprites, vx=0, bounced=False):
        self.x         = x
        self.y         = y
        self.vx        = vx
        self.vy        = vy
        self.kind      = kind
        self.sheet     = sprites["bolt"]
        self.tick      = 0
        self.frame_idx = 0
        self.bounced   = bounced

    def update(self):
        self.x += self.vx
        self.y += self.vy
        self.tick += 1
        if self.tick >= ANIM_RATE:
            self.tick = 0
            self.frame_idx = (self.frame_idx + 1) % 2

    def off_screen(self):
        return (self.y < -10 or self.y > HEIGHT + 10
                or self.x < -10 or self.x > WIDTH + 10)

    def rect(self):
        return pygame.Rect(self.x - 4, self.y - 8, 8, 16)

    def draw(self, surface):
        idx   = self.FRAMES[self.kind][self.frame_idx]
        frame = self.sheet.get(idx)
        fw, fh = frame.get_size()
        surface.blit(frame, (self.x - fw // 2, self.y - fh // 2))


# ── Explosion ─────────────────────────────────────────────────────────────────
class Explosion:
    TOTAL_FRAMES = 5

    def __init__(self, x, y, sprites):
        self.x         = x
        self.y         = y
        self.sheet     = sprites["expl"]
        self.tick      = 0
        self.frame_idx = 0
        self.done      = False

    def update(self):
        self.tick += 1
        if self.tick >= ANIM_RATE:
            self.tick = 0
            self.frame_idx += 1
            if self.frame_idx >= self.TOTAL_FRAMES:
                self.done = True

    def rect(self):
        frame = self.sheet.get(self.frame_idx)
        fw, fh = frame.get_size()
        return pygame.Rect(self.x - fw // 2, self.y - fh // 2, fw, fh)

    def draw(self, surface):
        if self.done:
            return
        frame  = self.sheet.get(self.frame_idx)
        fw, fh = frame.get_size()
        surface.blit(frame, (self.x - fw // 2, self.y - fh // 2))


# ── Enemy ─────────────────────────────────────────────────────────────────────
class Enemy:
    WIDTH       = 32
    HEIGHT      = 32
    ENTRY_SPEED = 3.0
    N_FRAMES    = {"e_big": 2, "e_med": 4, "e_sml": 2}
    MAX_HP      = {"e_sml": 2, "e_med": 3, "e_big": 5}
    FLASH_DUR   = 12   # frames (0.2 s at 60 fps)

    def __init__(self, target_x, target_y, key, sprites, entry_delay=0):
        self.target_x     = float(target_x)
        self.target_y     = float(target_y)
        self.x            = float(target_x)
        self.y            = -50.0
        self.key          = key
        self.sheet        = sprites[key]
        self.n_frames     = self.N_FRAMES[key]
        self.alive        = True
        self.hp           = self.MAX_HP[key]
        self.flash_timer  = 0
        self.entry_delay  = entry_delay
        self.delay_timer  = 0
        self.in_formation = False
        # set by EnemyFleet after construction
        self.offset_x     = 0.0
        self.patrol_x     = float(target_x)
        self.patrol_range = 55.0
        self.patrol_dx    = 1.0
        self.entry_speed  = self.ENTRY_SPEED

    def update_entry(self):
        if self.in_formation:
            return
        if self.delay_timer < self.entry_delay:
            self.delay_timer += 1
            return
        dy = self.target_y - self.y
        if abs(dy) <= self.entry_speed:
            self.y = self.target_y
            self.in_formation = True
        else:
            self.y += self.entry_speed

    def hit(self):
        """Register one hit. Returns True if the enemy is now dead."""
        self.hp -= 1
        self.flash_timer = self.FLASH_DUR
        if self.hp <= 0:
            self.alive = False
            return True
        return False

    def rect(self):
        hw, hh = self.WIDTH // 2, self.HEIGHT // 2
        return pygame.Rect(int(self.x) - hw, int(self.y) - hh, self.WIDTH, self.HEIGHT)

    def draw(self, surface, frame_idx):
        if self.y + self.HEIGHT // 2 < 0:
            return
        frame = self.sheet.get(frame_idx % self.n_frames)
        if self.flash_timer > 0:
            frame = frame.copy()
            red = pygame.Surface(frame.get_size())
            red.fill((160, 0, 0))
            frame.blit(red, (0, 0), special_flags=pygame.BLEND_RGB_ADD)
        fw, fh = frame.get_size()
        surface.blit(frame, (int(self.x) - fw // 2, int(self.y) - fh // 2))


# ── Enemy fleet ───────────────────────────────────────────────────────────────
class EnemyFleet:
    STEP_DOWN = 18   # default; overridden per-wave via "step_down" config key

    def __init__(self, wave_config, sprites):
        self.movement       = wave_config.get("movement", "A")
        self.step_down      = wave_config.get("step_down", self.STEP_DOWN)
        self.shoot_interval = wave_config["shoot_interval"]
        self.sprites        = sprites

        stagger     = wave_config.get("entry_stagger", 8)
        entry_speed = wave_config.get("entry_speed", Enemy.ENTRY_SPEED)
        self.enemies = [
            Enemy(x, y, key, sprites, entry_delay=i * stagger)
            for i, (x, y, key) in enumerate(wave_config["enemies"])
        ]
        for e in self.enemies:
            e.entry_speed = entry_speed
        self.total_enemies = len(self.enemies)

        # ── formation geometry (A, B, E) ────────────────────────────────────
        xs = [e.target_x for e in self.enemies]
        init_cx = sum(xs) / len(xs)
        self.formation_half_w = (max(xs) - min(xs)) / 2 + Enemy.WIDTH // 2

        # ── A / E: locked block drift ────────────────────────────────────────
        self.anchor_x  = init_cx
        self.anchor_dx = float(wave_config.get("h_speed", 1.0))

        # ── B: sine oscillation ──────────────────────────────────────────────
        self.sine_t         = 0
        self.sine_center    = init_cx
        self.sine_amplitude = float(wave_config.get("sine_amplitude", 60))
        self.sine_frequency = float(wave_config.get("sine_frequency", 0.02))

        # ── D: descent ───────────────────────────────────────────────────────
        self.descent_speed = float(wave_config.get("descent_speed", 0.4))

        # ── E: scatter flag ──────────────────────────────────────────────────
        self.scattered = False

        # ── entry y: preserve formation depth so shape stays intact during descent
        min_ty = min(e.target_y for e in self.enemies)
        for e in self.enemies:
            e.y = -50.0 - (e.target_y - min_ty)

        # ── per-enemy patrol / offset attributes ─────────────────────────────
        patrol_range = float(wave_config.get("patrol_range", 55))
        h_speed      = float(wave_config.get("h_speed", 1.0))
        for e in self.enemies:
            e.offset_x    = e.target_x - init_cx
            e.patrol_x    = e.target_x
            e.patrol_range = patrol_range
            e.patrol_dx   = h_speed * random.choice([-1.0, 1.0])

        # ── shared animation / shooting ──────────────────────────────────────
        self.shoot_timer   = 0
        self.anim_tick     = 0
        self.frame_idx     = 0
        self.tick          = 0          # master frame counter for burst timing
        self.pending_shots = []         # [(fire_at_tick, x, y), ...]

    # ── helpers ──────────────────────────────────────────────────────────────
    def alive_enemies(self):
        return [e for e in self.enemies if e.alive]

    @property
    def all_in_formation(self):
        return all(e.in_formation for e in self.enemies if e.alive)

    # ── movement dispatch ─────────────────────────────────────────────────────
    def _move(self, living):
        m = self.movement

        if m == "A":
            self.anchor_x += self.anchor_dx
            if (self.anchor_x + self.formation_half_w >= WIDTH or
                    self.anchor_x - self.formation_half_w <= 0):
                self.anchor_dx *= -1
                for e in living:
                    e.y += self.step_down
            for e in living:
                e.x = self.anchor_x + e.offset_x

        elif m == "B":
            self.sine_t += 1
            self.anchor_x = (self.sine_center +
                             self.sine_amplitude * math.sin(self.sine_t * self.sine_frequency))
            for e in living:
                e.x = self.anchor_x + e.offset_x

        elif m == "C":
            for e in living:
                e.x += e.patrol_dx
                lo, hi = e.patrol_x - e.patrol_range, e.patrol_x + e.patrol_range
                if e.x >= hi or e.x <= lo:
                    e.patrol_dx *= -1
                    e.x = max(lo, min(hi, e.x))

        elif m == "D":
            ratio = len(living) / max(self.total_enemies, 1)
            speed = self.descent_speed / max(ratio, 0.2)
            for e in living:
                e.y += speed

        elif m == "E":
            alive_ratio = len(living) / self.total_enemies
            if not self.scattered and alive_ratio <= 0.5:
                self.scattered = True
            if not self.scattered:
                # locked block (A)
                self.anchor_x += self.anchor_dx
                if (self.anchor_x + self.formation_half_w >= WIDTH or
                        self.anchor_x - self.formation_half_w <= 0):
                    self.anchor_dx *= -1
                    for e in living:
                        e.y += self.step_down
                for e in living:
                    e.x = self.anchor_x + e.offset_x
            else:
                # individual patrol (C)
                for e in living:
                    e.x += e.patrol_dx
                    lo, hi = e.patrol_x - e.patrol_range, e.patrol_x + e.patrol_range
                    if e.x >= hi or e.x <= lo:
                        e.patrol_dx *= -1
                        e.x = max(lo, min(hi, e.x))

    # ── separation pass ───────────────────────────────────────────────────────
    def _separate(self, living):
        """Push overlapping enemies apart so sprites never touch."""
        MIN_H = 36  # horizontal center-to-center (32px width + 4px gap)
        MIN_V = 34  # vertical center-to-center (32px height + 2px gap)
        for _ in range(4):     # multiple passes resolve cascading overlaps
            for i in range(len(living)):
                for j in range(i + 1, len(living)):
                    ei, ej = living[i], living[j]
                    if abs(ei.y - ej.y) >= MIN_V:
                        continue  # vertically separated — no overlap possible
                    dx = ej.x - ei.x
                    overlap = MIN_H - abs(dx)
                    if overlap <= 0:
                        continue
                    push = overlap / 2 + 0.5
                    if dx >= 0:
                        ei.x -= push
                        ej.x += push
                        # reverse whichever is moving toward the other
                        if ei.patrol_dx > 0: ei.patrol_dx *= -1
                        if ej.patrol_dx < 0: ej.patrol_dx *= -1
                    else:
                        ei.x += push
                        ej.x -= push
                        if ei.patrol_dx < 0: ei.patrol_dx *= -1
                        if ej.patrol_dx > 0: ej.patrol_dx *= -1
        # keep enemies inside screen bounds after pushing
        half = Enemy.WIDTH // 2
        for e in living:
            e.x = max(half, min(WIDTH - half, e.x))

    # ── main update ───────────────────────────────────────────────────────────
    def update(self):
        living = self.alive_enemies()
        if not living:
            return []

        for e in living:
            if e.flash_timer > 0:
                e.flash_timer -= 1
            e.update_entry()

        if self.all_in_formation:
            self._move(living)
            self._separate(living)

        # ── shooting ─────────────────────────────────────────────────────────
        self.tick        += 1
        self.shoot_timer += 1
        shots = []

        # emit any pending burst bullets that are due this tick
        due = [(t, x, y) for (t, x, y) in self.pending_shots if self.tick >= t]
        for entry in due:
            self.pending_shots.remove(entry)
            shots.append(Bullet(entry[1], entry[2], 4, "enemy", self.sprites))

        if self.shoot_timer >= self.shoot_interval:
            in_pos = [e for e in living if e.in_formation]
            if in_pos:
                self.shoot_timer = 0
                shooter = random.choice(in_pos)
                sx, sy = shooter.x, shooter.y + 10
                if shooter.key == "e_sml":
                    # single shot straight down
                    shots.append(Bullet(sx, sy, 4, "enemy", self.sprites))
                elif shooter.key == "e_med":
                    # 3-bullet spread
                    for vx in (-2, 0, 2):
                        shots.append(Bullet(sx, sy, 4, "enemy", self.sprites, vx=vx))
                else:  # e_big — burst: 3 bullets 8 frames apart
                    for i in range(3):
                        self.pending_shots.append((self.tick + i * 8, sx, sy))

        self.anim_tick += 1
        if self.anim_tick >= ANIM_RATE:
            self.anim_tick = 0
            self.frame_idx += 1

        return shots

    def draw(self, surface):
        for e in self.enemies:
            if e.alive:
                e.draw(surface, self.frame_idx)


# ── Boss ──────────────────────────────────────────────────────────────────────
class Boss:
    WIDTH  = 96
    HEIGHT = 96
    MAX_HP = 150

    # (sine_amplitude, sine_frequency) per phase
    SINE_PARAMS = {1: (120, 0.008), 2: (150, 0.014), 3: (150, 0.020)}

    # frames between spread shots per phase
    SPREAD_INTERVAL  = {1: 90, 2: 70, 3: 50}
    AIMED_INTERVAL   = 60   # phase 2+
    RING_INTERVAL    = 120  # phase 3
    MINION_INTERVAL  = 480  # phase 3: new minion wave every 8 seconds

    BULLET_SPEED = 4

    def __init__(self, sprites):
        self.sprites       = sprites
        self.sheet         = sprites["boss"]
        self.x             = float(WIDTH // 2)
        self.y             = float(self.HEIGHT // 2 + 20)
        self.hp            = self.MAX_HP
        self.phase         = 1
        self.sine_t        = 0
        self.frame_idx     = 0
        self.anim_tick     = 0
        self.spread_timer  = 0
        self.aimed_timer   = 0
        self.ring_timer    = 0
        self.minion_timer  = 0
        self.lunge_dy      = 0.0   # current vertical lunge velocity
        self.lunge_timer   = 0    # frames left in lunge
        self.lunge_cd      = 0    # cooldown before next lunge
        self.alive         = True
        self.flash_timer   = 0    # white flash on phase change
        self.drop_timers   = []   # list of [frames_remaining, kind]
        self.pending_blasts = []  # list of [frames_remaining, ox, oy]
        self.freeze_timer  = 0    # freeze movement during phase transition

    @property
    def _phase(self):
        if self.hp > 100: return 1
        if self.hp > 50:  return 2
        return 3

    def rect(self):
        hw, hh = self.WIDTH // 2, self.HEIGHT // 2
        return pygame.Rect(int(self.x) - hw, int(self.y) - hh, self.WIDTH, self.HEIGHT)

    def hit(self):
        if not self.alive:
            return
        self.hp -= 1
        new_phase = self._phase
        if new_phase != self.phase:
            self.phase       = new_phase
            self.flash_timer = 20
            if new_phase in (2, 3):   # end of phase 1 or 2
                self.drop_timers.append([0, "heart"])
                # queue 6 explosions, 0.5 s (30 frames) apart, random offset 5-35 px
                for i in range(6):
                    angle = random.uniform(0, 2 * math.pi)
                    dist  = random.randint(5, 35)
                    ox    = int(math.cos(angle) * dist)
                    oy    = int(math.sin(angle) * dist)
                    self.pending_blasts.append([i * 30, ox, oy])
                self.freeze_timer = 5 * 30 + 1  # hold still until last blast fires

    def update(self, player_x, player_y):
        """Returns (shots, drops, blasts) — blasts are (ox, oy) offsets from boss center."""
        shots  = []
        drops  = []
        blasts = []

        # ── pending pickups ───────────────────────────────────────────────────
        still_pending = []
        for entry in self.drop_timers:
            entry[0] -= 1
            if entry[0] <= 0:
                drops.append(entry[1])
            else:
                still_pending.append(entry)
        self.drop_timers = still_pending

        # ── pending phase-transition blasts ──────────────────────────────────
        still_blasts = []
        for entry in self.pending_blasts:
            entry[0] -= 1
            if entry[0] <= 0:
                blasts.append((entry[1], entry[2]))
            else:
                still_blasts.append(entry)
        self.pending_blasts = still_blasts

        if self.freeze_timer > 0:
            self.freeze_timer -= 1
            if self.freeze_timer == 0:
                # re-sync sine_t so the first movement frame after freeze
                # produces exactly the current x (no position jump)
                amp, freq = self.SINE_PARAMS[self._phase]
                val = max(-1.0, min(1.0, (self.x - WIDTH / 2) / amp))
                # set sine_t one step behind so after += 1 it lands exactly here
                self.sine_t = math.asin(val) / freq - 1

        # phase tracking
        self.phase = self._phase

        # ── movement (frozen during phase transition) ─────────────────────────
        if self.freeze_timer == 0:
            amp, freq = self.SINE_PARAMS[self.phase]
            self.sine_t += 1
            self.x = WIDTH / 2 + amp * math.sin(self.sine_t * freq)

        # phase 2+ vertical lunge (also frozen during transition)
        if self.phase >= 2 and self.freeze_timer == 0:
            if self.lunge_cd > 0:
                self.lunge_cd -= 1
            elif self.lunge_timer <= 0:
                # start a new lunge toward player
                self.lunge_timer = 30
                self.lunge_dy    = (1 if player_y > self.y else -1) * 2.5
                self.lunge_cd    = 180
            if self.lunge_timer > 0:
                self.y += self.lunge_dy
                self.lunge_timer -= 1
                if self.lunge_timer == 0:
                    self.lunge_dy = 0.0

        # keep boss in upper third
        self.y = max(self.HEIGHT // 2 + 10, min(HEIGHT // 3, self.y))

        # ── animation ─────────────────────────────────────────────────────────
        self.anim_tick += 1
        if self.anim_tick >= ANIM_RATE:
            self.anim_tick = 0
            self.frame_idx = (self.frame_idx + 1) % 2

        if self.flash_timer > 0:
            self.flash_timer -= 1

        # ── spread shot (all phases) ───────────────────────────────────────
        self.spread_timer += 1
        if self.spread_timer >= self.SPREAD_INTERVAL[self.phase]:
            self.spread_timer = 0
            for i in range(6):
                angle_deg = -60 + i * 24   # -60°, -36°, -12°, +12°, +36°, +60°
                angle_rad = math.radians(angle_deg)
                vx = math.sin(angle_rad) * self.BULLET_SPEED
                vy = math.cos(angle_rad) * self.BULLET_SPEED
                shots.append(Bullet(self.x, self.y + self.HEIGHT // 2,
                                    vy, "enemy", self.sprites, vx=vx))

        # ── aimed shot (phase 2+) ─────────────────────────────────────────
        if self.phase >= 2:
            self.aimed_timer += 1
            if self.aimed_timer >= self.AIMED_INTERVAL:
                self.aimed_timer = 0
                dx = player_x - self.x
                dy = player_y - self.y
                dist = math.hypot(dx, dy) or 1
                vx = (dx / dist) * self.BULLET_SPEED
                vy = (dy / dist) * self.BULLET_SPEED
                shots.append(Bullet(self.x, self.y, vy, "enemy",
                                    self.sprites, vx=vx))

        # ── ring burst (phase 3) ──────────────────────────────────────────
        if self.phase >= 3:
            self.ring_timer += 1
            if self.ring_timer >= self.RING_INTERVAL:
                self.ring_timer = 0
                for i in range(8):
                    angle_rad = math.radians(i * 45)
                    vx = math.cos(angle_rad) * self.BULLET_SPEED
                    vy = math.sin(angle_rad) * self.BULLET_SPEED
                    shots.append(Bullet(self.x, self.y, vy, "enemy",
                                        self.sprites, vx=vx))

        return shots, drops, blasts

    def draw(self, surface):
        frame  = self.sheet.get(self.frame_idx)
        fw, fh = frame.get_size()
        blit_x = int(self.x) - fw // 2
        blit_y = int(self.y) - fh // 2
        if self.flash_timer > 0 and self.flash_timer % 4 < 2:
            # white flash: tint the frame
            flash = frame.copy()
            flash.fill((255, 255, 255, 160), special_flags=pygame.BLEND_RGBA_ADD)
            surface.blit(flash, (blit_x, blit_y))
        else:
            surface.blit(frame, (blit_x, blit_y))

    def draw_hp_bar(self, surface, font):
        bar_w, bar_h = 200, 10
        bx = (WIDTH - bar_w) // 2
        by = 36
        pygame.draw.rect(surface, (60, 10, 10),  (bx, by, bar_w, bar_h))
        fill = int(bar_w * max(self.hp, 0) / self.MAX_HP)
        pygame.draw.rect(surface, (200, 30, 30), (bx, by, fill, bar_h))
        pygame.draw.rect(surface, (255, 80, 80), (bx, by, bar_w, bar_h), 1)
        label = font.render("THE ARCHITECT", True, (255, 80, 80))
        surface.blit(label, ((WIDTH - label.get_width()) // 2, by - label.get_height() - 2))


# ── Background ────────────────────────────────────────────────────────────────
class ParallaxBackground:


    BG_SPEED    = 0.4
    CLOUD_SPEED = 1.4

    def __init__(self):
        _base = os.path.join(os.path.dirname(__file__), "Assets", "Desert", "backgrounds")

        def load_scaled(path, alpha=False):
            raw = pygame.image.load(path)
            raw = raw.convert_alpha() if alpha else raw.convert()
            iw, ih = raw.get_size()
            nh = int(ih * WIDTH / iw)
            return pygame.transform.scale(raw, (WIDTH, nh))

        self.bg      = load_scaled(os.path.join(_base, "desert-backgorund.png"))
        self.clouds  = load_scaled(os.path.join(_base, "clouds-transparent.png"), alpha=True)
        self.bg_h    = self.bg.get_height()
        self.cloud_h = self.clouds.get_height()
        self.bg_y    = 0.0
        self.cloud_y = 0.0

    def update(self):
        self.bg_y    = (self.bg_y    + self.BG_SPEED)    % self.bg_h
        self.cloud_y = (self.cloud_y + self.CLOUD_SPEED) % self.cloud_h

    def draw(self, surface):
        y = int(self.bg_y) - self.bg_h
        while y < HEIGHT:
            surface.blit(self.bg, (0, y))
            y += self.bg_h
        y = int(self.cloud_y) - self.cloud_h
        while y < HEIGHT:
            surface.blit(self.clouds, (0, y))
            y += self.cloud_h


# ── Pickup ────────────────────────────────────────────────────────────────────
# Heart fall speed: enemy entry speed (3.0) × 1.25 = 3.75 px/frame
# Clover fall speed: heart speed × 1.25 = 4.6875 px/frame
class Pickup:
    SIZE         = 32   # display size (16px sprite × scale 2)
    SPEED_HEART  = Enemy.ENTRY_SPEED * 1.25
    SPEED_CLOVER = SPEED_HEART * 1.25

    def __init__(self, x, y, kind, sprites):
        self.x      = float(x)
        self.y      = float(y)
        self.kind   = kind   # "heart" or "clover"
        self.sprite = sprites[kind].get(3)
        self.speed  = self.SPEED_HEART if kind == "heart" else self.SPEED_CLOVER

    def update(self):
        self.y += self.speed

    def off_screen(self):
        return self.y - self.SIZE // 2 > HEIGHT

    def rect(self):
        h = self.SIZE // 2
        return pygame.Rect(int(self.x) - h, int(self.y) - h, self.SIZE, self.SIZE)

    def draw(self, surface):
        fw, fh = self.sprite.get_size()
        surface.blit(self.sprite, (int(self.x) - fw // 2, int(self.y) - fh // 2))


# ── HUD ───────────────────────────────────────────────────────────────────────
def draw_hud(surface, font, score, player, wave_idx, muted=False):
    surface.blit(font.render(f"SCORE  {score:06d}", True, WHITE), (10, 10))
    lives_text = font.render("LIVES " + "♥ " * player.lives, True, RED)
    surface.blit(lives_text, (WIDTH - lives_text.get_width() - 10, 10))
    name_text = font.render(WAVE_NAMES[wave_idx], True, CYAN)
    surface.blit(name_text, ((WIDTH - name_text.get_width()) // 2, 10))
    # ── mute indicator ───────────────────────────────────────────────────────
    mute_label = font.render("MUTE" if muted else "M", True,
                             (200, 80, 80) if muted else (80, 80, 80))
    surface.blit(mute_label, (10, HEIGHT - mute_label.get_height() - 8))



def draw_centered(surface, font, text, y, color=WHITE):
    rendered = font.render(text, True, color)
    surface.blit(rendered, ((WIDTH - rendered.get_width()) // 2, y))


# ── Main game loop ────────────────────────────────────────────────────────────
def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption(TITLE)
    clock = pygame.time.Clock()

    _font_path  = os.path.join(os.path.dirname(__file__), "Assets", "fonts", "PressStart2P-Regular.ttf")
    font_big   = pygame.font.Font(_font_path, 16)
    font_small = pygame.font.Font(_font_path,  8)
    font_title = pygame.font.Font(_font_path, 24)

    sprites = load_sprites()
    bg      = ParallaxBackground()

    pygame.mixer.init()
    _snd_dir = os.path.join(os.path.dirname(__file__), "Assets", "sounds")
    snd_player_shoot = pygame.mixer.Sound(os.path.join(_snd_dir, "sfx_player_shoot.ogg"))
    snd_enemy_shoot  = pygame.mixer.Sound(os.path.join(_snd_dir, "sfx_enemy_shoot.ogg"))
    snd_explosion    = pygame.mixer.Sound(os.path.join(_snd_dir, "sfx_explosion.ogg"))
    snd_wave_start   = pygame.mixer.Sound(os.path.join(_snd_dir, "sfx_wave_start.ogg"))
    snd_heart_pickup = pygame.mixer.Sound(os.path.join(_snd_dir, "sfx_wave_start.ogg"))
    snd_player_shoot.set_volume(0.5)
    snd_enemy_shoot.set_volume(0.4)
    snd_explosion.set_volume(0.6)
    snd_wave_start.set_volume(0.7)
    snd_heart_pickup.set_volume(0.35)

    player           = None
    fleet            = None
    boss             = None
    boss_minions     = None
    boss_timer       = 0      # boss_intro countdown
    boss_death_queue = []     # [[timer, x, y], ...] pending death explosions
    p_bullets:  list = []
    e_bullets:  list = []
    explosions: list = []
    pickups:    list = []
    HEART_DROP_RATE  = 0.08
    muted            = False
    score            = 0
    current_wave     = 0
    wave_timer       = 0
    wave_clear_timer = 0
    shake_timer      = 0
    menu_sel         = 0
    pause_sel        = 0
    prev_state       = "playing"
    STATE            = "menu"
    MENU_ITEMS       = ["START GAME", "EXIT GAME"]
    PAUSE_ITEMS      = ["RESUME", "QUIT"]

    def start_game():
        nonlocal player, fleet, boss, boss_minions, boss_timer, boss_death_queue, p_bullets, e_bullets, explosions, pickups, score, current_wave, wave_timer
        player       = Player(sprites)
        fleet        = None
        boss             = None
        boss_minions     = None
        boss_timer       = 0
        boss_death_queue = []
        p_bullets    = []
        e_bullets    = []
        explosions   = []
        pickups      = []
        score        = 0
        current_wave = 0
        wave_timer   = WAVE_INTRO_DURATION

    def launch_wave():
        nonlocal fleet, p_bullets, e_bullets, explosions
        cfg  = dict(WAVE_CONFIGS[current_wave])
        keep = round(len(cfg["enemies"]) * 0.75)   # all waves trimmed to 75%
        cfg["enemies"] = cfg["enemies"][:keep]
        fleet      = EnemyFleet(cfg, sprites)
        p_bullets  = []
        e_bullets  = []
        explosions = []
        if not muted: snd_wave_start.play()

    while True:
        clock.tick(FPS)
        bg.update()

        # ── Events ──────────────────────────────────────────────────────────
        fire_pressed = None
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_w and STATE not in ("menu",):
                    start_game()
                    boss       = Boss(sprites)
                    boss_timer = 0
                    STATE      = "boss"
                elif event.key == pygame.K_m:
                    muted = not muted
                    if muted:
                        pygame.mixer.pause()
                    else:
                        pygame.mixer.unpause()
                elif STATE == "menu":
                    if event.key in (pygame.K_UP, pygame.K_DOWN):
                        menu_sel = 1 - menu_sel
                    elif event.key in (pygame.K_RETURN, pygame.K_SPACE):
                        if menu_sel == 0:
                            start_game()
                            STATE = "wave_intro"
                        else:
                            pygame.quit()
                            sys.exit()
                elif STATE == "wave_intro":
                    if event.key == pygame.K_ESCAPE:
                        pause_sel  = 0
                        prev_state = "wave_intro"
                        STATE      = "paused"
                    elif event.key == pygame.K_SPACE:
                        wave_timer = 0
                elif STATE == "wave_clear":
                    if event.key == pygame.K_ESCAPE:
                        pause_sel  = 0
                        prev_state = "wave_clear"
                        STATE      = "paused"
                elif STATE == "playing":
                    if event.key == pygame.K_ESCAPE:
                        pause_sel  = 0
                        prev_state = "playing"
                        STATE      = "paused"
                    elif event.key in (pygame.K_z, pygame.K_x):
                        fire_pressed = event.key
                elif STATE == "paused":
                    if event.key == pygame.K_ESCAPE:
                        STATE = prev_state
                    elif event.key in (pygame.K_UP, pygame.K_DOWN):
                        pause_sel = 1 - pause_sel
                    elif event.key in (pygame.K_RETURN, pygame.K_SPACE):
                        if pause_sel == 0:
                            STATE = prev_state
                        else:
                            menu_sel = 0
                            STATE    = "menu"
                elif STATE == "boss_intro":
                    if event.key == pygame.K_ESCAPE:
                        pause_sel  = 0
                        prev_state = "boss_intro"
                        STATE      = "paused"
                elif STATE == "boss":
                    if event.key == pygame.K_ESCAPE:
                        pause_sel  = 0
                        prev_state = "boss"
                        STATE      = "paused"
                    elif event.key in (pygame.K_z, pygame.K_x):
                        fire_pressed = event.key
                elif STATE in ("game_over", "win"):
                    if event.key == pygame.K_r:
                        menu_sel = 0
                        STATE    = "menu"

        # ── Update ──────────────────────────────────────────────────────────
        if STATE == "wave_intro":
            keys = pygame.key.get_pressed()
            player.update(keys)
            wave_timer -= 1
            if wave_timer <= 0:
                launch_wave()
                STATE = "playing"

        elif STATE == "wave_clear":
            keys = pygame.key.get_pressed()
            player.update(keys)
            for b  in p_bullets:  b.update()
            for b  in e_bullets:  b.update()
            p_bullets  = [b for b in p_bullets if not b.off_screen()]
            e_bullets  = [b for b in e_bullets if not b.off_screen()]
            for b in e_bullets[:]:
                if b.rect().colliderect(player.rect()):
                    e_bullets.remove(b)
                    if player.hit():
                        shake_timer = 20
            for pk in pickups: pk.update()
            for pk in pickups[:]:
                if pk.rect().colliderect(player.rect()):
                    pickups.remove(pk)
                    if pk.kind == "heart":
                        player.lives = min(player.lives + 1, 7)
                        if not muted: snd_heart_pickup.play()
            pickups = [pk for pk in pickups if not pk.off_screen()]
            for ex in explosions: ex.update()
            explosions = [ex for ex in explosions if not ex.done]
            if not explosions and not e_bullets and not pickups:
                wave_clear_timer -= 1
                if wave_clear_timer <= 0:
                    if current_wave < len(WAVE_CONFIGS) - 1:
                        current_wave += 1
                        wave_timer   = WAVE_INTRO_DURATION
                        STATE        = "wave_intro"
                    else:
                        boss       = Boss(sprites)
                        boss_timer = WAVE_INTRO_DURATION
                        STATE      = "boss_intro"

        elif STATE == "playing":
            keys = pygame.key.get_pressed()
            fired = player.update(keys, fire_pressed)
            for b in fired:
                p_bullets.append(b)
                if not muted: snd_player_shoot.play()

            for b  in p_bullets:  b.update()
            for b  in e_bullets:  b.update()
            for ex in explosions: ex.update()

            p_bullets  = [b  for b  in p_bullets  if not b.off_screen()]
            e_bullets  = [b  for b  in e_bullets  if not b.off_screen()]
            explosions = [ex for ex in explosions if not ex.done]

            enemy_shots = fleet.update()
            if enemy_shots:
                e_bullets.extend(enemy_shots)
                if not muted: snd_enemy_shoot.play()

            # Player bullets vs enemies
            for b in p_bullets[:]:
                for e in fleet.alive_enemies():
                    if b.rect().colliderect(e.rect()):
                        p_bullets.remove(b)
                        if e.hit():
                            score += 10
                            explosions.append(Explosion(e.x, e.y, sprites))
                            if not muted: snd_explosion.play()
                            if random.random() < HEART_DROP_RATE:
                                pickups.append(Pickup(e.x, e.y, "heart", sprites))
                        break

            # Explosions vs enemies
            for ex in explosions:
                for e in fleet.alive_enemies():
                    if e.rect().colliderect(ex.rect()):
                        if e.hit():
                            score += 10
                            explosions.append(Explosion(e.x, e.y, sprites))
                            if not muted: snd_explosion.play()
                            if random.random() < HEART_DROP_RATE:
                                pickups.append(Pickup(e.x, e.y, "heart", sprites))

            # Enemy bullets vs player (no collision while invincible)
            if player.invincible == 0:
                for b in e_bullets[:]:
                    if b.rect().colliderect(player.rect()):
                        e_bullets.remove(b)
                        if player.hit():
                            shake_timer = 20

            # Player body vs enemy body (no collision while invincible)
            if player.invincible == 0:
                for e in fleet.alive_enemies():
                    if e.rect().colliderect(player.rect()):
                        e.alive = False
                        explosions.append(Explosion(e.x, e.y, sprites))
                        if not muted: snd_explosion.play()
                        if player.hit():
                            shake_timer = 20

            # Pickups fall and are collected
            for pk in pickups: pk.update()
            for pk in pickups[:]:
                if pk.rect().colliderect(player.rect()):
                    pickups.remove(pk)
                    if pk.kind == "heart":
                        player.lives = min(player.lives + 1, 7)
                        if not muted: snd_heart_pickup.play()
            pickups = [pk for pk in pickups if not pk.off_screen()]

            # Enemy reaches bottom of screen → lose one life, enemy silently removed
            for e in fleet.alive_enemies():
                if e.y + Enemy.HEIGHT // 2 >= HEIGHT:
                    e.alive = False
                    player.lives -= 1   # no exception: bypasses invincibility
                    shake_timer = 20

            # Wave / game transitions
            if player.lives <= 0:
                STATE = "game_over"
            elif not fleet.alive_enemies():
                wave_clear_timer   = 60   # 1 second after last explosion
                STATE              = "wave_clear"
                player.facing      = "default"
                player.frame_idx   = 0

        elif STATE == "boss_intro":
            keys = pygame.key.get_pressed()
            player.update(keys)
            boss_timer -= 1
            if boss_timer <= 0:
                p_bullets  = []
                e_bullets  = []
                explosions = []
                if not muted: snd_wave_start.play()
                STATE = "boss"

        elif STATE == "boss":
            keys = pygame.key.get_pressed()
            fired = player.update(keys, fire_pressed)
            for b in fired:
                p_bullets.append(b)
                if not muted: snd_player_shoot.play()

            for b  in p_bullets:  b.update()
            for b  in e_bullets:  b.update()
            for ex in explosions: ex.update()
            p_bullets  = [b  for b  in p_bullets  if not b.off_screen()]
            e_bullets  = [b  for b  in e_bullets  if not b.off_screen()]
            explosions = [ex for ex in explosions if not ex.done]

            # boss minion fleet
            if boss_minions:
                minion_shots = boss_minions.update()
                if minion_shots:
                    e_bullets.extend(minion_shots)
                    if not muted: snd_enemy_shoot.play()
                # minion reaches bottom → lose life
                for e in boss_minions.alive_enemies():
                    if e.y + Enemy.HEIGHT // 2 >= HEIGHT:
                        e.alive = False
                        player.lives -= 1
                        shake_timer = 20
                if not boss_minions.alive_enemies():
                    boss_minions = None

            # boss fires, drops, and phase-transition blasts
            boss_shots, boss_drops, boss_blasts = boss.update(player.x, player.y)
            if boss_shots:
                e_bullets.extend(boss_shots)
                if not muted: snd_enemy_shoot.play()
            for kind in boss_drops:
                pickups.append(Pickup(boss.x, boss.y + Boss.HEIGHT // 2, kind, sprites))
            for ox, oy in boss_blasts:
                explosions.append(Explosion(boss.x + ox, boss.y + oy, sprites))
                if not muted: snd_explosion.play()

            # phase 3: spawn minions periodically
            if boss.phase >= 3 and boss_minions is None:
                boss.minion_timer += 1
                if boss.minion_timer >= Boss.MINION_INTERVAL:
                    boss.minion_timer = 0
                    wave_idx = random.randint(0, len(WAVE_CONFIGS) - 1)
                    mcfg = dict(WAVE_CONFIGS[wave_idx])
                    keep = max(1, round(len(mcfg["enemies"]) * 0.50))
                    mcfg["enemies"] = mcfg["enemies"][:keep]
                    boss_minions = EnemyFleet(mcfg, sprites)

            # player bullets vs boss
            for b in p_bullets[:]:
                if b.rect().colliderect(boss.rect()):
                    p_bullets.remove(b)
                    score += 50
                    boss.hit()
                    if not muted: snd_explosion.play()
                    if random.random() < HEART_DROP_RATE:
                        pickups.append(Pickup(boss.x, boss.y + Boss.HEIGHT // 2, "heart", sprites))
                    break

            # player bullets vs boss minions
            if boss_minions:
                for b in p_bullets[:]:
                    for e in boss_minions.alive_enemies():
                        if b.rect().colliderect(e.rect()):
                            p_bullets.remove(b)
                            if e.hit():
                                score += 10
                                explosions.append(Explosion(e.x, e.y, sprites))
                                if not muted: snd_explosion.play()
                            break

            # explosions vs boss minions
            if boss_minions:
                for ex in explosions:
                    for e in boss_minions.alive_enemies():
                        if e.rect().colliderect(ex.rect()):
                            if e.hit():
                                score += 10
                                explosions.append(Explosion(e.x, e.y, sprites))
                                if not muted: snd_explosion.play()

            # enemy bullets vs player
            if player.invincible == 0:
                for b in e_bullets[:]:
                    if b.rect().colliderect(player.rect()):
                        e_bullets.remove(b)
                        if player.hit():
                            shake_timer = 20

            # boss body vs player
            if player.invincible == 0:
                if boss.rect().colliderect(player.rect()):
                    if player.hit():
                        shake_timer = 20

            # boss minions vs player
            if player.invincible == 0 and boss_minions:
                for e in boss_minions.alive_enemies():
                    if e.rect().colliderect(player.rect()):
                        e.alive = False
                        explosions.append(Explosion(e.x, e.y, sprites))
                        if not muted: snd_explosion.play()
                        if player.hit():
                            shake_timer = 20

            # pickups fall and are collected
            for pk in pickups: pk.update()
            for pk in pickups[:]:
                if pk.rect().colliderect(player.rect()):
                    pickups.remove(pk)
                    if pk.kind == "heart":
                        player.lives = min(player.lives + 1, 7)
                        if not muted: snd_heart_pickup.play()
            pickups = [pk for pk in pickups if not pk.off_screen()]

            # boss death → build 30-explosion queue and freeze
            if boss.hp <= 0 and boss.alive:
                boss.alive = False
                t = 0
                for _ in range(22):
                    x = random.randint(Boss.WIDTH // 2, WIDTH  - Boss.WIDTH // 2)
                    y = random.randint(Boss.HEIGHT // 2, HEIGHT - Boss.HEIGHT // 2)
                    boss_death_queue.append([t, x, y, []])
                    t += random.randint(12, 30)  # 0.2–0.5 s between each
                # assign living minions to a random explosion between index 4 and 17
                if boss_minions:
                    for e in boss_minions.alive_enemies():
                        idx = random.randint(4, 17)
                        boss_death_queue[idx][3].append(e)
                STATE = "boss_death"

            # transitions
            if player.lives <= 0:
                STATE = "game_over"

        elif STATE == "boss_death":
            # advance existing explosions
            for ex in explosions: ex.update()
            explosions = [ex for ex in explosions if not ex.done]
            # fire queued explosions whose timer has elapsed
            still = []
            for entry in boss_death_queue:
                entry[0] -= 1
                if entry[0] <= 0:
                    explosions.append(Explosion(entry[1], entry[2], sprites))
                    for e in entry[3]:
                        e.alive = False
                        explosions.append(Explosion(e.x, e.y, sprites))
                    if not muted: snd_explosion.play()
                else:
                    still.append(entry)
            boss_death_queue[:] = still
            # once all queued and all finished → win
            if not boss_death_queue and not explosions:
                STATE = "win"

        # ── Draw ────────────────────────────────────────────────────────────
        bg.draw(screen)

        if STATE == "menu":
            draw_centered(screen, font_title, "CLAUDE",   HEIGHT // 2 - 160, CYAN)
            draw_centered(screen, font_title, "INVADERS", HEIGHT // 2 - 100, WHITE)
            pygame.draw.line(screen, CYAN,
                             (60, HEIGHT // 2 - 52), (WIDTH - 60, HEIGHT // 2 - 52), 1)
            for i, label in enumerate(MENU_ITEMS):
                color  = CYAN  if i == menu_sel else WHITE
                prefix = ">  " if i == menu_sel else "   "
                draw_centered(screen, font_big, prefix + label,
                              HEIGHT // 2 - 20 + i * 52, color)
            draw_centered(screen, font_small, "UP / DOWN    navigate",  HEIGHT - 70, (100, 100, 100))
            draw_centered(screen, font_small, "ENTER / SPACE  select",  HEIGHT - 48, (100, 100, 100))

        elif STATE == "wave_intro":
            if player:
                player.draw(screen)
                draw_hud(screen, font_small, score, player, current_wave, muted)
            if (wave_timer // 15) % 2 == 0:
                draw_centered(screen, font_big, WAVE_NAMES[current_wave],
                              HEIGHT // 2 - 16, CYAN)

        elif STATE in ("playing", "wave_clear", "game_over", "win"):
            if fleet:  fleet.draw(screen)
            if player: player.draw(screen)
            for b  in p_bullets:  b.draw(screen)
            for b  in e_bullets:  b.draw(screen)
            for ex in explosions: ex.draw(screen)
            for pk in pickups:    pk.draw(screen)
            draw_hud(screen, font_small, score, player, current_wave, muted)

        elif STATE == "boss_death":
            bg.draw(screen)
            if boss_minions: boss_minions.draw(screen)
            if player:       player.draw(screen)
            for b  in p_bullets:  b.draw(screen)
            for b  in e_bullets:  b.draw(screen)
            for pk in pickups:    pk.draw(screen)
            for ex in explosions: ex.draw(screen)

        elif STATE == "boss_intro":
            if player: player.draw(screen)
            if (boss_timer // 15) % 2 == 0:
                draw_centered(screen, font_big, "THE ARCHITECT", HEIGHT // 2 - 16, RED)

        elif STATE == "boss":
            if boss and boss.alive: boss.draw(screen)
            if boss_minions:        boss_minions.draw(screen)
            if player:              player.draw(screen)
            for b  in p_bullets:  b.draw(screen)
            for b  in e_bullets:  b.draw(screen)
            for ex in explosions: ex.draw(screen)
            for pk in pickups:    pk.draw(screen)
            if boss: boss.draw_hp_bar(screen, font_small)
            # draw lives / score / mute (no wave name during boss)
            screen.blit(font_small.render(f"SCORE  {score:06d}", True, WHITE), (10, 10))
            lives_text = font_small.render("LIVES " + "♥ " * player.lives, True, RED)
            screen.blit(lives_text, (WIDTH - lives_text.get_width() - 10, 10))
            mute_label = font_small.render("MUTE" if muted else "M", True,
                                           (200, 80, 80) if muted else (80, 80, 80))
            screen.blit(mute_label, (10, HEIGHT - mute_label.get_height() - 8))

        if STATE == "paused":
            if boss and boss.alive: boss.draw(screen)
            if fleet:  fleet.draw(screen)
            if player: player.draw(screen)
            for b  in p_bullets:  b.draw(screen)
            for b  in e_bullets:  b.draw(screen)
            for ex in explosions: ex.draw(screen)
            for pk in pickups:    pk.draw(screen)
            if boss:
                boss.draw_hp_bar(screen, font_small)
            else:
                draw_hud(screen, font_small, score, player, current_wave, muted)
            overlay = pygame.Surface((WIDTH, HEIGHT), pygame.SRCALPHA)
            overlay.fill((0, 0, 0, 140))
            screen.blit(overlay, (0, 0))
            draw_centered(screen, font_big, "PAUSED", HEIGHT // 2 - 60, CYAN)
            for i, label in enumerate(PAUSE_ITEMS):
                color  = CYAN  if i == pause_sel else WHITE
                prefix = ">  " if i == pause_sel else "   "
                draw_centered(screen, font_big, prefix + label,
                              HEIGHT // 2 + i * 48, color)

        if STATE == "game_over":
            draw_centered(screen, font_big,   "GAME OVER",           HEIGHT // 2 - 30, RED)
            draw_centered(screen, font_small, f"SCORE  {score:06d}", HEIGHT // 2 + 10)
            draw_centered(screen, font_small, "press R for menu",     HEIGHT // 2 + 40, CYAN)

        if STATE == "win":
            draw_centered(screen, font_big,   "YOU WIN!",            HEIGHT // 2 - 30, YELLOW)
            draw_centered(screen, font_small, f"SCORE  {score:06d}", HEIGHT // 2 + 10)
            draw_centered(screen, font_small, "press R for menu",     HEIGHT // 2 + 40, CYAN)


        # ── screen shake ────────────────────────────────────────────────────
        if shake_timer > 0:
            intensity = (shake_timer / 20) * 6
            ox = int(random.uniform(-intensity, intensity))
            oy = int(random.uniform(-intensity, intensity))
            frame = screen.copy()
            screen.fill((0, 0, 0))
            screen.blit(frame, (ox, oy))
            shake_timer -= 1

        pygame.display.flip()


if __name__ == "__main__":
    main()
