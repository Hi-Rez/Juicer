import Easings
import Foundation

public class Tween: CustomStringConvertible {
    // Properties
    public private(set) var id: String = UUID().uuidString
    public private(set) var label: String = "Tween"
    public private(set) var loops: Int = 0
    public private(set) var loop: Int = 0
    
    public private(set) var tweening: Bool = false
    public private(set) var complete: Bool = false
    public private(set) var looping: Bool = false
    public private(set) var pingPong: Bool = false
    public private(set) var pingPongState: Bool = false
    public private(set) var progress: Double = 0.0
    
    public private(set) var delayOnLoop: Bool = false
    public private(set) var delayOnPingPong: Bool = false
    
    // Easing
    public var easingFn: ((_ time: Double) -> Double) = easeLinear
    
    // Callbacks
    private var _onStart: (() -> ())?
    private var _onRestart: (() -> ())?
    private var _onPlay: (() -> ())?
    private var _onPause: (() -> ())?
    private var _onStop: (() -> ())?
    private var _onUpdate: ((_ progress: Double) -> ())?
    private var _onTweenStart: (() -> ())?
    private var _onTween: ((_ value: Double) -> ())?
    private var _onComplete: (() -> ())?
    private var _onLoopsComplete: (() -> ())?
    private var _onPingPongComplete: (() -> ())?
    
    private var firstTime: Bool = true
    private var delay: CFTimeInterval = 0.0
    private var duration: CFTimeInterval = 0.0
    private var startTime: CFTimeInterval = 0.0 {
        didSet {
            lastDeltaTime = -1.0
        }
    }

    private var lastDeltaTime: CFTimeInterval = 0.0
    
    public var description: String {
        label
    }
    
    internal init(duration: Double) {
        self.duration = duration
    }
    
    public func restart() -> Tween {
        loop = 0
        _onRestart?()
        return start()
    }
    
    public func start() -> Tween {
        if complete {
            Tweener.append(self)
        }
        tweening = true
        complete = false
        startTime = CFAbsoluteTimeGetCurrent() + ((firstTime || delayOnLoop || (delayOnPingPong && !pingPongState)) ? delay : 0.0)
        updateProgress()
        _onStart?()
        firstTime = false
        return self
    }
    
    public func onRestart(_ restartFn: @escaping (() -> ())) -> Tween {
        _onRestart = restartFn
        return self
    }
    
    public func onStart(_ startFn: @escaping (() -> ())) -> Tween {
        _onStart = startFn
        return self
    }
    
    public func onPlay(_ playFn: @escaping (() -> ())) -> Tween {
        _onPlay = playFn
        return self
    }
    
    public func onPause(_ pauseFn: @escaping (() -> ())) -> Tween {
        _onPause = pauseFn
        return self
    }
    
    public func onStop(_ stopFn: @escaping (() -> ())) -> Tween {
        _onStop = stopFn
        return self
    }
    
    public func onUpdate(_ updateFn: @escaping ((_ progress: Double) -> ())) -> Tween {
        _onUpdate = updateFn
        return self
    }
    
    public func onTweenStart(_ tweenStartFn: @escaping (() -> ())) -> Tween {
        _onTweenStart = tweenStartFn
        return self
    }
    
    public func onTween(_ tweenFn: @escaping ((_ progress: Double) -> ())) -> Tween {
        _onTween = tweenFn
        return self
    }
    
    public func onEasing(_ easingFn: @escaping ((_ time: Double) -> Double)) -> Tween {
        self.easingFn = easingFn
        return self
    }
    
    public func onComplete(_ completeFn: @escaping (() -> ())) -> Tween {
        _onComplete = completeFn
        return self
    }
    
    public func onLoopsComplete(_ loopsCompleteFn: @escaping (() -> ())) -> Tween {
        _onLoopsComplete = loopsCompleteFn
        return self
    }
    
    public func onPingPongComplete(_ pingPongCompleteFn: @escaping (() -> ())) -> Tween {
        _onPingPongComplete = pingPongCompleteFn
        return self
    }
    
    public func play() -> Tween {
        if complete {
            return restart()
        }
        else {
            tweening = true
            startTime = CFAbsoluteTimeGetCurrent() - progress * duration
        }
        _onPlay?()
        return self
    }
    
    public func pause() {
        updateProgress()
        tweening = false
        _onPause?()
    }
    
    public func stop() {
        updateProgress()
        tweening = false
        _onStop?()
        progress = 0.0
    }
    
    public func pingPong(_ pingPong: Bool = true) -> Tween {
        self.pingPong = pingPong
        return self
    }
    
    public func delay(_ delay: Double, onLoop: Bool = false, onPingPing: Bool = false) -> Tween {
        self.delay = delay
        delayOnLoop = onLoop
        delayOnPingPong = onPingPing
        return self
    }
    
    public func loop(_ looping: Bool = true) -> Tween {
        self.looping = looping
        return self
    }
    
    public func duration(_ duration: Double) -> Tween {
        self.duration = duration
        return self
    }
    
    public func loops(_ count: Int) -> Tween {
        loops = count
        return self
    }
    
    public func easing(_ easing: Easing) -> Tween {
        switch easing {
        case .linear:
            easingFn = easeLinear
        case .smoothstep:
            easingFn = easeSmoothstep
        case .inSine:
            easingFn = easeInSine
        case .outSine:
            easingFn = easeOutSine
        case .inOutSine:
            easingFn = easeInOutSine
        case .inQuad:
            easingFn = easeInQuad
        case .outQuad:
            easingFn = easeOutQuad
        case .inOutQuad:
            easingFn = easeInOutQuad
        case .inCubic:
            easingFn = easeInCubic
        case .outCubic:
            easingFn = easeOutCubic
        case .inOutCubic:
            easingFn = easeInOutCubic
        case .inQuart:
            easingFn = easeInQuart
        case .outQuart:
            easingFn = easeOutQuart
        case .inOutQuart:
            easingFn = easeInOutQuart
        case .inQuint:
            easingFn = easeInQuint
        case .outQuint:
            easingFn = easeOutQuint
        case .inOutQuint:
            easingFn = easeInOutQuint
        case .inExpo:
            easingFn = easeInExpo
        case .outExpo:
            easingFn = easeOutExpo
        case .inOutExpo:
            easingFn = easeInOutExpo
        case .inCirc:
            easingFn = easeInCirc
        case .outCirc:
            easingFn = easeOutCirc
        case .inOutCirc:
            easingFn = easeInOutCirc
        case .inBack:
            easingFn = easeInBack
        case .outBack:
            easingFn = easeOutBack
        case .inOutBack:
            easingFn = easeInOutBack
        case .inElastic:
            easingFn = easeInElastic
        case .outElastic:
            easingFn = easeOutElastic
        case .inOutElastic:
            easingFn = easeInOutElastic
        case .inBounce:
            easingFn = easeInBounce
        case .outBounce:
            easingFn = easeOutBounce
        case .inOutBounce:
            easingFn = easeInOutBounce
        }
        return self
    }
    
    public func labeled(_ label: String) -> Tween {
        self.label = label
        return self
    }
    
    func pingPong(_ progress: Double) -> Double {
        if pingPong, pingPongState {
            return 1.0 - progress
        }
        return progress
    }
    
    internal func updateProgress() {
        guard tweening else { return }
        let deltaTime = (CFAbsoluteTimeGetCurrent() - startTime)
        if deltaTime >= 0.0 && lastDeltaTime < 0.0 {
            _onTweenStart?()
        }
        lastDeltaTime = deltaTime
        progress = deltaTime / duration
    }
    
    internal func update() {
        updateProgress()
        
        guard tweening, progress >= 0.0 else { return }

        let _progress = pingPong(min(max(progress, 0.0), 1.0))
        let _tween = easingFn(_progress)

        _onUpdate?(_progress)
        _onTween?(_tween)

        if progress >= 1.0 {
            loop += 1
            
            complete = true
            tweening = false
            
            _onComplete?()
            
            var restart = false
            
            var loopsLeft = Int.max
            if !looping, loops > 0 {
                loopsLeft = loops - loop
                if loopsLeft == 0 {
                    _onLoopsComplete?()
                }
            }
            
            if pingPong, loopsLeft > 0 {
                pingPongState = !pingPongState
                if pingPongState {
                    restart = true
                }
                else {
                    _onPingPongComplete?()
                }
            }
            
            if looping || (loops > 0 && loopsLeft > 0) {
                restart = true
            }
            
            if restart {
                _ = start()
            }
        }
    }
    
    deinit {}
}

extension Tween: Equatable {
    public static func == (lhs: Tween, rhs: Tween) -> Bool {
        return lhs.id == rhs.id
    }
}
