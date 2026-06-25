import UIKit
import QuartzCore

class ViewController: UIViewController {

    // Игровые элементы
    var ball: UIView!
    var playerPaddle: UIView!
    var computerPaddle: UIView!
    var playerScoreLabel: UILabel!
    var computerScoreLabel: UILabel!
    
    // Игровой цикл
    var gameTimer: CADisplayLink!
    
    // Физика мяча
    var ballVelocityX: CGFloat = 4.0
    var ballVelocityY: CGFloat = 4.0
    
    // Счет
    var playerScore: Int = 0
    var computerScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем черный фон поля
        self.view.backgroundColor = UIColor.blackColor()
        
        setupGameElements()
        resetBall()
        
        // Запуск игрового цикла (60 FPS) с правильным синтаксисом селектора для Swift 1.2/2.0
        gameTimer = CADisplayLink(target: self, selector: Selector("updateGame"))
        gameTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func setupGameElements() {
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        // Разделительная линия по центру
        let middleLine = UIView(frame: CGRect(x: 0, y: viewHeight / 2 - 1, width: viewWidth, height: 2))
        middleLine.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(middleLine)
        
        // Счет игрока (снизу)
        playerScoreLabel = UILabel(frame: CGRect(x: 20, y: viewHeight / 2 + 20, width: 50, height: 50))
        playerScoreLabel.text = "0"
        playerScoreLabel.textColor = UIColor.whiteColor()
        playerScoreLabel.font = UIFont.systemFontOfSize(36)
        self.view.addSubview(playerScoreLabel)
        
        // Счет компьютера (сверху)
        computerScoreLabel = UILabel(frame: CGRect(x: 20, y: viewHeight / 2 - 70, width: 50, height: 50))
        computerScoreLabel.text = "0"
        computerScoreLabel.textColor = UIColor.whiteColor()
        computerScoreLabel.font = UIFont.systemFontOfSize(36)
        self.view.addSubview(computerScoreLabel)
        
        // Ракетка компьютера (сверху)
        computerPaddle = UIView(frame: CGRect(x: viewWidth / 2 - 40, y: 40, width: 80, height: 15))
        computerPaddle.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(computerPaddle)
        
        // Ракетка игрока (снизу)
        playerPaddle = UIView(frame: CGRect(x: viewWidth / 2 - 40, y: viewHeight - 55, width: 80, height: 15))
        playerPaddle.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(playerPaddle)
        
        // Мяч
        ball = UIView(frame: CGRect(x: viewWidth / 2 - 10, y: viewHeight / 2 - 10, width: 20, height: 20))
        ball.backgroundColor = UIColor.whiteColor()
        ball.layer.cornerRadius = 10 // Делаем мяч круглым
        self.view.addSubview(ball)
    }
    
    func resetBall() {
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        ball.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        
        // Случайное направление при старте (совместимо со старым Swift)
        ballVelocityX = arc4random_uniform(2) == 0 ? 4.0 : -4.0
        ballVelocityY = arc4random_uniform(2) == 0 ? 4.0 : -4.0
    }
    
    // Главный игровой цикл
    func updateGame() {
        // Движение мяча
        ball.center = CGPoint(x: ball.center.x + ballVelocityX, y: ball.center.y + ballVelocityY)
        
        let viewWidth = self.view.bounds.width
        let viewHeight = self.view.bounds.height
        
        // Отскок от левой и правой стен
        if ball.frame.origin.x <= 0 || ball.frame.origin.x + ball.frame.size.width >= viewWidth {
            ballVelocityX = -ballVelocityX
        }
        
        // Логика ИИ для верхней ракетки
        let targetX = ball.center.x - computerPaddle.frame.size.width / 2
        let speed: CGFloat = 3.5 
        if computerPaddle.frame.origin.x < targetX {
            computerPaddle.frame.origin.x += speed
        } else if computerPaddle.frame.origin.x > targetX {
            computerPaddle.frame.origin.x -= speed
        }
        
        // Проверка столкновения с ракеткой игрока
        if CGRectIntersectsRect(ball.frame, playerPaddle.frame) {
            if ballVelocityY > 0 {
                ballVelocityY = -ballVelocityY
                let hitPoint = ball.center.x - playerPaddle.center.x
                ballVelocityX = hitPoint * 0.1
            }
        }
        
        // Проверка столкновения с ракеткой компьютера
        if CGRectIntersectsRect(ball.frame, computerPaddle.frame) {
            if ballVelocityY < 0 {
                ballVelocityY = -ballVelocityY
                let hitPoint = ball.center.x - computerPaddle.center.x
                ballVelocityX = hitPoint * 0.1
            }
        }
        
        // Гол компьютеру (мяч улетел наверх)
        if ball.frame.origin.y <= 0 {
            playerScore += 1
            playerScoreLabel.text = "\(playerScore)"
            resetBall()
        }
        
        // Гол игроку (мяч улетел вниз)
        if ball.frame.origin.y >= viewHeight {
            computerScore += 1
            computerScoreLabel.text = "\(computerScore)"
            resetBall()
        }
    }
    
    // Управление игроком (совместимо с iOS 7 с использованием NSObject/UITouch)
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        handleTouches(touches)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        handleTouches(touches)
    }
    
    func handleTouches(touches: Set<NSObject>) {
        if let touch = touches.first as? UITouch {
            let touchLocation = touch.locationInView(self.view)
            let viewWidth = self.view.bounds.width
            
            var newX = touchLocation.x - playerPaddle.frame.size.width / 2
            if newX < 0 { newX = 0 }
            if newX > viewWidth - playerPaddle.frame.size.width { newX = viewWidth - playerPaddle.frame.size.width }
            
            playerPaddle.frame.origin.x = newX
        }
    }
    
    // Блокируем поворот экрана
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}

// Позволяет приложению запускаться без Storyboard и xib файлов напрямую из кода
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

// Главная точка входа в приложение
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
