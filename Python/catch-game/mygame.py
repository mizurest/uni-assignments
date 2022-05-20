import pygame
from pygame.locals import *
import time
import random

class App():
    w, h = 1366, 768
    playerHeight = 600
    def __init__(self):
        self.fps, self.f = 60, True
        self.v = 20
        pygame.init()
        self.screen = pygame.display.set_mode((App.w, App.h))
        pygame.display.set_caption('星集めゲーム')
        self.score, self.timeLimit = 0, 30
        self.clock = pygame.time.Clock()
        self.p = Player()
        self.font = pygame.font.Font('./font/mplus-2p-light.ttf', 30)        
        self.mv, self.mv2 = 10, 10

        # Sound
        self.startSound = pygame.mixer.Sound("./sound/start.wav")
        self.shootSound = pygame.mixer.Sound("./sound/shoot.wav")
        self.catchSound = pygame.mixer.Sound("./sound/catch.wav")
        self.breakSound = pygame.mixer.Sound("./sound/break.wav")
        self.damageSound = pygame.mixer.Sound("./sound/damage.wav")

        # State
        self.isRight = False
        self.isStart = False
        self.isEnd = False
        self.c = []
        self.s = []
        self.b = []
        self.time = 0
         
        self.main()
             
    def main(self):
        while self.f:
            self.draw()
            self.ev()

    def draw(self):
        self.screen.fill((88, 90, 100))

        if(self.isEnd): #終了画面
            text = self.font.render("  YOUR SCORE is " + str(self.score) + ", PRESS R KEY to RETRY   " , True, (255, 255, 255), (255, 127, 127))
            textpos = text.get_rect()
            textpos.centerx = self.screen.get_rect().centerx  # X座標
            textpos.centery = self.screen.get_rect().centery   # Y座標
            self.screen.blit(text, textpos)
        
        else:
            if(self.isStart): #プレイ画面
                self.time += 1
                nowTime = self.timeLimit-int((self.time/self.fps))
                
                if(nowTime < 1): # タイムアップ時
                    self.isStart = False
                    self.isEnd = True

                self.screen.blit(self.p.img, self.p.r) #プレイヤーの描写

                if(random.randint(0, 100) > 95): # 星を生成
                    self.s.append(Star(random.randint(0, App.w), 0))

                if(random.randint(0, 200) > 199): # 爆弾を生成
                    self.b.append(Bomb(random.randint(0, App.w), 0))
                    
                for i,item in enumerate(self.s):
                    item.r.move_ip(0, self.mv)
                    self.screen.blit(item.img, item.r)
                    if item.r.y > App.h: #弾が画面外に出た場合
                        self.s.pop(i)
                    if(item.r.colliderect(self.p.r)): #プレイヤーが取得した場合
                        self.catchSound.play()
                        self.score += 100
                        self.s.pop(i)
                    if(item.r.collidelist(self.c) > -1): #弾が当たった場合
                        self.breakSound.play()
                        self.s.pop(i)

                for i,item in enumerate(self.b):
                    item.r.move_ip(0, self.mv)
                    self.screen.blit(item.img, item.r)
                    if item.r.y > App.h: #弾が画面外に出た場合
                        self.b.pop(i)
                    if(item.r.colliderect(self.p.r)): #プレイヤーが取得した場合
                        self.damageSound.play()
                        self.score -= 500
                        self.b.pop(i)
                    if(item.r.collidelist(self.c) > -1): #弾が当たった場合
                        self.breakSound.play()
                        self.b.pop(i)

                for i,item in enumerate(self.c): #弾の数だけ繰り返し
                    item.move_ip(0, -self.mv) #弾の移動処理
                    pygame.draw.circle(self.screen, (127, 255, 127), (item.x, item.y), item.w/2) #弾の描画処理
                    if item.y < 0: #弾が画面外に出た場合
                        self.c.pop(i)
            
                status = "SCORE: " + str(self.score) + "   "
                status += " TIME LIMIT: " + str(nowTime)
                self.txt = self.font.render(status, True, (220, 220, 220))
                self.screen.blit(self.txt, (20, 10))

            else: #開始画面
                text = self.font.render("  PRESS SPACE KEY to START  ", True, (255, 255, 255), (255, 127, 127)) 
                
                textpos = text.get_rect()
                textpos.centerx = self.screen.get_rect().centerx  # X座標
                textpos.centery = self.screen.get_rect().centery   # Y座標
                self.screen.blit(text, textpos)
        
        pygame.display.update()
        self.clock.tick(self.fps)
        
    def ev(self):
        pressed_key = pygame.key.get_pressed()
        
        if(self.isStart):
            # 画面外に移動できないようにする
            if(self.p.r.x < 0): self.p.r.x = 0
            if(self.p.r.x > App.w-self.p.w): self.p.r.x = App.w-self.p.w

            if(pressed_key[K_LEFT]): 
                self.isRight = False
                self.p.img = self.p.img1
                self.p.move(-self.v, 0)
                
            if(pressed_key[K_RIGHT]): 
                self.isRight = True
                self.p.img = self.p.img2
                self.p.move(self.v, 0)
        
        else:
            if( pressed_key[K_SPACE] and self.isEnd == False ): # ゲーム開始
                self.isStart = True
                self.startSound.play()
            if( pressed_key[K_r] and self.isEnd ): # ゲームリトライ
                self.isEnd = False
                self.c = []
                self.s = []
                self.time = self.score = 0
                self.startSound.play()
            
        for event in pygame.event.get():
            if(event.type == QUIT): self.f = False
            if(event.type == KEYDOWN and event.key == K_ESCAPE): self.f = False
            if(self.isStart):
                if(pressed_key[K_UP]):
                    cx = self.p.r.x
                    cy = self.p.r.y
                    cx += Player.w/2
                    self.c.append(Rect(cx, cy, 20, 20)) #円（弾）
                    self.shootSound.play()
            
class Player():
    w, h = 300, 300
    def __init__(self):
        self.r = Rect(App.w/2, App.playerHeight, Player.w, Player.h)
        self.j, self.vy = True, 0
        self.img1 = self.img = pygame.image.load("./img/p2.png")
        self.img2 = pygame.transform.flip(self.img, True, False)
            
    def move(self, x, y):
        self.r.move_ip(x, y)

class Star():
    def __init__(self, x, y):
        self.r = Rect(x, y, 65, 61)
        self.img = pygame.image.load("./img/star.png")
    
    def move(self, x, y):
        self.r.move_ip(x, y)

class Bomb():
    def __init__(self, x, y):
        self.r = Rect(x, y, 100, 100)
        self.img = pygame.image.load("./img/bomb.png")

    def move(self, x, y):
        self.r.move_ip(x, y)

if __name__ == '__main__': App()