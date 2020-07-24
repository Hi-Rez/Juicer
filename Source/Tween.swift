import Foundation

public class Tween {
    public var _onStart: (() -> ())?
    public var _onUpdate: ((_ time: Double) -> ())?
    public var _onComplete: (() -> ())?

    public var tweening: Bool = false
    public var complete: Bool = false
    public var looping: Bool = false

    private var delay: CFTimeInterval = 0.0
    private var duration: CFTimeInterval = 0.0
    private var startTime: CFTimeInterval = 0.0

    init(duration: Double, delay: Double = 0.0) {
        self.duration = duration
        self.delay = delay
    }

    public func start() -> Tween {
        tweening = true
        startTime = CFAbsoluteTimeGetCurrent() + delay
        _onStart?()
        return self
    }
    
    public func loop(looping: Bool = true) -> Tween {
        self.looping = looping
        return self
    }

    internal func update() {
        guard tweening else { return }
        let deltaTime = (CFAbsoluteTimeGetCurrent() - startTime)
        guard deltaTime >= 0 else { return }
        let time = deltaTime / duration
        _onUpdate?(max(min(1.0, time), 0.0))
        if time >= 1.0 {
            complete = true
            _onComplete?()
            if self.looping {
                complete = false
                _ = start()
            }
        }
    }

    public func onStart(_ startFn: @escaping (() -> ())) -> Tween {
        _onStart = startFn
        return self
    }

    public func onUpdate(_ updateFn: @escaping ((_ time: Double) -> ())) -> Tween {
        _onUpdate = updateFn
        return self
    }

    public func onComplete(_ completeFn: @escaping (() -> ())) -> Tween {
        _onComplete = completeFn
        return self
    }

    deinit {
        print("killing tween!")
    }
}
