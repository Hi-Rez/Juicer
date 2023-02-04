import QuartzCore
import Satin

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
            DispatchQueue.main.async {
                Tweener.update()
            }
        }
        return kCVReturnSuccess
    }

    #else

    private static var displayLink: CADisplayLink?

    private class func setupDisplayLink() {
        if Tweener.displayLink == nil {
            Tweener.displayLink = CADisplayLink(target: self, selector: #selector(Tweener.update))
            Tweener.displayLink!.add(to: .main, forMode: .default)
        }
    }

    #endif

    private class func stopDisplayLink() {
        if let displayLink = Tweener.displayLink {
            #if os(macOS)
            CVDisplayLinkStop(displayLink)
            #elseif os(iOS)
            displayLink.invalidate()
            #endif
            Tweener.displayLink = nil
        }
    }

    deinit {
        Tweener.stopDisplayLink()
        Tweener.tweens = []
    }

    @objc private class func update() {
        for (index, tween) in tweens.enumerated().reversed() {
            tween.update()
            if tween.complete {
                tweens.remove(at: index)
            }
        }

        if tweens.isEmpty, let _ = Tweener.displayLink {
            Tweener.stopDisplayLink()
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
        tweens.append(tween.onTween { [weak object] (progress: Double) in
            object?.position = simd_mix(from, to, simd_float3(repeating: Float(progress)))
        })
        return tween
    }

    public class func tweenPosition(duration: Double, object: Satin.Object, to: simd_float3) -> Tween {
        setupDisplayLink()
        var from: simd_float3 = object.position
        let tween = Tween(duration: duration)
            .onTweenStart { [weak object] in
                from = object?.position ?? from
            }
            .onTween { [weak object] (progress: Double) in
                object?.position = simd_mix(from, to, simd_float3(repeating: Float(progress)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenScale(duration: Double, object: Satin.Object, from: simd_float3, to: simd_float3) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [weak object] (progress: Double) in
            object?.scale = simd_mix(from, to, simd_float3(repeating: Float(progress)))
        })
        return tween
    }

    public class func tweenScale(duration: Double, object: Satin.Object, to: simd_float3) -> Tween {
        setupDisplayLink()
        var from: simd_float3 = object.scale
        let tween = Tween(duration: duration)
            .onTweenStart { [weak object] in
                from = object?.scale ?? from
            }
            .onTween { [weak object] (progress: Double) in
                object?.scale = simd_mix(from, to, simd_float3(repeating: Float(progress)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenOrientation(duration: Double, object: Satin.Object, from: simd_quatf, to: simd_quatf) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
        tweens.append(tween.onTween { [weak object] (value: Double) in
            object?.orientation = simd_slerp(from, to, Float(value))
        })
        return tween
    }

    public class func tweenOrientation(duration: Double, object: Satin.Object, to: simd_quatf) -> Tween {
        setupDisplayLink()
        var from: simd_quatf = object.orientation
        let tween = Tween(duration: duration)
            .onTweenStart { [weak object] in
                from = object?.orientation ?? from
            }
            .onTween { [weak object] (value: Double) in
                object?.orientation = simd_slerp(from, to, Float(value))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.FloatParameter, from: Float, to: Float) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, Float(value))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.FloatParameter, to: Float) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, Float(value))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: DoubleParameter, from: Double, to: Double) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, value)
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: DoubleParameter, to: Double) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, value)
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float2Parameter, from: simd_float2, to: simd_float2) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float2(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float2Parameter, to: simd_float2) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float2(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float3Parameter, from: simd_float3, to: simd_float3) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float3(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float3Parameter, to: simd_float3) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float3(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float4Parameter, from: simd_float4, to: simd_float4) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float4(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Satin.Float4Parameter, to: simd_float4) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_mix(from, to, simd_float4(repeating: Float(value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: IntParameter, from: Int, to: Int) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = Int(simd_mix(Double(from), Double(to), value))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: IntParameter, to: Int) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = Int(simd_mix(Double(from), Double(to), value))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int2Parameter, from: simd_int2, to: simd_int2) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int2(simd_mix(simd_double2(from), simd_double2(to), simd_double2(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int2Parameter, to: simd_int2) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int2(simd_mix(simd_double2(from), simd_double2(to), simd_double2(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int3Parameter, from: simd_int3, to: simd_int3) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int3(simd_mix(simd_double3(from), simd_double3(to), simd_double3(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int3Parameter, to: simd_int3) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int3(simd_mix(simd_double3(from), simd_double3(to), simd_double3(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int4Parameter, from: simd_int4, to: simd_int4) -> Tween {
        setupDisplayLink()
        let tween = Tween(duration: duration)
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int4(simd_mix(simd_double4(from), simd_double4(to), simd_double4(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenParameter(duration: Double, parameter: Int4Parameter, to: simd_int4) -> Tween {
        setupDisplayLink()
        var from = parameter.value
        let tween = Tween(duration: duration)
            .onTweenStart { [weak parameter] in
                from = parameter?.value ?? from
            }
            .onTween { [weak parameter] (value: Double) in
                parameter?.value = simd_int4(simd_mix(simd_double4(from), simd_double4(to), simd_double4(repeating: value)))
            }
        tweens.append(tween)
        return tween
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: Float, to: Float) -> Tween? {
        guard let parameter = material.get(key) as? FloatParameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: Float) -> Tween? {
        guard let parameter = material.get(key) as? FloatParameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_float2, to: simd_float2) -> Tween? {
        guard let parameter = material.get(key) as? Float2Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_float2) -> Tween? {
        guard let parameter = material.get(key) as? Float2Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_float3, to: simd_float3) -> Tween? {
        guard let parameter = material.get(key) as? Float3Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_float3) -> Tween? {
        guard let parameter = material.get(key) as? Float3Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_float4, to: simd_float4) -> Tween? {
        guard let parameter = material.get(key) as? Float4Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_float4) -> Tween? {
        guard let parameter = material.get(key) as? Float4Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: Int, to: Int) -> Tween? {
        guard let parameter = material.get(key) as? IntParameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: Int) -> Tween? {
        guard let parameter = material.get(key) as? IntParameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_int2, to: simd_int2) -> Tween? {
        guard let parameter = material.get(key) as? Int2Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_int2) -> Tween? {
        guard let parameter = material.get(key) as? Int2Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_int3, to: simd_int3) -> Tween? {
        guard let parameter = material.get(key) as? Int3Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_int3) -> Tween? {
        guard let parameter = material.get(key) as? Int3Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, from: simd_int4, to: simd_int4) -> Tween? {
        guard let parameter = material.get(key) as? Int4Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, from: from, to: to)
    }

    public class func tweenMaterial(duration: Double, material: Material, key: String, to: simd_int4) -> Tween? {
        guard let parameter = material.get(key) as? Int4Parameter else { return nil }
        return tweenParameter(duration: duration, parameter: parameter, to: to)
    }

    public class func append(_ tween: Tween) {
        setupDisplayLink()
        if !tweens.contains(tween) {
            tweens.append(tween)
        }
    }
}
