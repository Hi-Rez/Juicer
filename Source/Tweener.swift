import Foundation

public class Tweener {
    static let shared = Tweener()
    private static var tweens: [Tween] = []

    #if os(macOS)

    private static var displayLink: CVDisplayLink?

    private class func setupDisplayLink() {
        var cvReturn = CVDisplayLinkCreateWithActiveCGDisplays(&Tweener.displayLink)
        assert(cvReturn == kCVReturnSuccess)
        cvReturn = CVDisplayLinkSetOutputCallback(Tweener.displayLink!, Tweener.displayLoop, Unmanaged.passUnretained(Tweener.shared).toOpaque())
        assert(cvReturn == kCVReturnSuccess)
        cvReturn = CVDisplayLinkSetCurrentCGDisplay(Tweener.displayLink!, CGMainDisplayID())
        assert(cvReturn == kCVReturnSuccess)
        CVDisplayLinkStart(Tweener.displayLink!)
    }

    private static let displayLoop: CVDisplayLinkOutputCallback = {
        _, _, _, _, _, _ in
        autoreleasepool {
            Tweener.update()
        }
        return kCVReturnSuccess
    }

    #else

    private static var displayLink: CADisplayLink?

    private class func setupDisplayLink() {
        Tweener.displayLink = CADisplayLink(target: self, selector: #selector(Tweener.update))
        Tweener.displayLink!.add(to: .current, forMode: .default)
    }

    #endif

    @objc private class func update()
    {
        for (index, tween) in Tweener.tweens.enumerated() {
            tween.update()
            if tween.complete {
                Tweener.tweens.remove(at: index)
            }
        }
    }

    public class func tween(duration: Double) -> Tween {
        if Tweener.displayLink == nil {
            setupDisplayLink()
        }
        let tween = Tween(duration: duration)
        tweens.append(tween)
        return tween
    }
    
    public class func append(_ tween: Tween) {
        if Tweener.displayLink == nil {
            setupDisplayLink()
        }
        if !tweens.contains(tween) {
            tweens.append(tween)
        }
    }
}
