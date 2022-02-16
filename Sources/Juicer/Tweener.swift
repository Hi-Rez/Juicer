import Satin
import QuartzCore

public class Tweener {
    static let shared = Tweener()
    private static var tweens: [Tween] = []

    #if os(macOS)

    private static var displayLink: CVDisplayLink?

    private class func setupDisplayLink() {
        if Tweener.displayLink == nil {
            var cvReturn = CVDisplayLinkCreateWithActiveCGDisplays(&Tweener.displayLink)
            assert(cvReturn == kCVReturnSuccess)
            cvReturn = CVDisplayLinkSetOutputCallback(Tweener.displayLink!, Tweener.displayLoop, Unmanaged.passUnretained(Tweener.shared).toOpaque())
            assert(cvReturn == kCVReturnSuccess)
            cvReturn = CVDisplayLinkSetCurrentCGDisplay(Tweener.displayLink!, CGMainDisplayID())
            assert(cvReturn == kCVReturnSuccess)
            CVDisplayLinkStart(Tweener.displayLink!)
        }
    }

    private static let displayLoop: CVDisplayLinkOutputCallback = {
        _, _, _, _, _, _ in
        autoreleasepool {
            Tweener.update()
        }
        return kCVReturnSuccess
    }

    deinit {
        CVDisplayLinkStop(Tweener.displayLink!)
        Tweener.tweens = []
    }

    #else

    private static var displayLink: CADisplayLink?

    private class func setupDisplayLink() {
        if Tweener.displayLink == nil {
            Tweener.displayLink = CADisplayLink(target: self, selector: #selector(Tweener.update))
            Tweener.displayLink!.add(to: .main, forMode: .default)
        }
    }

    deinit {
        Tweener.displayLink!.invalidate()
        Tweener.tweens = []
    }

    #endif

    @objc private class func update() {
        for (index, tween) in tweens.enumerated().reversed() {
            tween.update()
            if tween.complete {
                tweens.remove(at: index)
            }
        }
    }

    public class func tween(duration: Double) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween)
        return tween
    }

    public class func tweenPosition(duration: Double, object: Satin.Object, from: simd_float3, to: simd_float3) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [object, from, to] (progress: Double) in
            object.position = simd_mix(from, to, simd_float3(repeating: Float(progress)))
        })
        return tween
    }
    
    public class func tweenPosition(duration: Double, object: Satin.Object, to: simd_float3) -> Tween {
        return tweenPosition(duration: duration, object: object, from: object.position, to: to)
    }
    
    public class func tweenParameter(duration: Double, parameter: Satin.FloatParameter, from: Float, to: Float) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [parameter, from, to] (value: Double) in
            parameter.value = simd_mix(from, to, Float(value))
        })
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.FloatParameter, to: Float) -> Tween {
        return tweenParameter(duration: duration, parameter: parameter, from: parameter.value, to: to)
    }
    
    public class func tweenScale(duration: Double, object: Satin.Object, from: simd_float3, to: simd_float3) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [object, from, to] (progress: Double) in
            object.scale = simd_mix(from, to, simd_float3(repeating: Float(progress)))
        })
        return tween
    }

    public class func tweenScale(duration: Double, object: Satin.Object, to: simd_float3) -> Tween {
        return tweenScale(duration: duration, object: object, from: object.scale, to: to)
    }

    public class func tweenOrientation(duration: Double, object: Satin.Object, from: simd_quatf, to: simd_quatf) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [object, from, to] (value: Double) in
            object.orientation = simd_slerp(from, to, Float(value))
        })
        return tween
    }

    public class func tweenOrientation(duration: Double, object: Satin.Object, to: simd_quatf) -> Tween {
        return tweenOrientation(duration: duration, object: object, from: object.orientation, to: to)
    }

    public class func append(_ tween: Tween) {
        setupDisplayLink()
        if !tweens.contains(tween) {
            tweens.append(tween)
        }
    }
}
