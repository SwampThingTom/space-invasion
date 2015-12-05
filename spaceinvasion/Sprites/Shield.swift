//
//  Shield.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/27/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    var bottomLeftPosition: CGPoint {
        return CGPoint(x: -size.width, y: -size.height) * anchorPoint
    }
    var bottomRightPosition: CGPoint {
        return CGPoint(x: size.width, y: -size.height) * anchorPoint
    }
    var topLeftPosition: CGPoint {
        return CGPoint(x: -size.width, y: size.height) * anchorPoint
    }
    var topRightPosition: CGPoint {
        return CGPoint(x: size.width, y: size.height) * anchorPoint
    }
}

class Shield: HittableSprite {
    
    let bombMask: CGImageRef
    let missileMask: CGImageRef
    let invaderMask: CGImageRef
    var image: CGImageRef
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Shield")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.zPosition = ScreenConstants.values.shieldZPosition
        self.physicsBody = Shield.physicsBodyForTexture(texture)
    }
    
    override required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        image = texture!.CGImage
        bombMask = Shield.loadImage(named: "ShieldBombMask")
        missileMask = Shield.loadImage(named: "ShieldMissileMask")
        invaderMask = Shield.loadImage(named: "ShieldInvaderMask")
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        let contactPosition = convertPoint(position, fromNode: scene!)
        guard let mask = maskForSprite(sprite, contactPosition: contactPosition) else {
            return
        }
        
        image = maskedImage(image, mask: mask.image, maskOrigin: mask.origin)
        self.texture = SKTexture(CGImage: image)
        self.physicsBody = Shield.physicsBodyForTexture(self.texture!)
    }
    
    private func maskForSprite(sprite: SKSpriteNode, contactPosition: CGPoint) -> (image: CGImageRef, origin: CGPoint)? {
        switch sprite {
        case is InvaderBomb:
            let contactOffset = CGPoint(x: size.width / 2 - sprite.size.width, y: sprite.size.height)
            return (bombMask, contactPosition + contactOffset)
        case is ShipMissile:
            let contactOffset = CGPoint(x: size.width / 2 - 3 * sprite.size.width, y: 2 * sprite.size.height)
            return (missileMask, contactPosition + contactOffset)
        case is Invader:
            let shieldOverlapPosition = convertPoint(sprite.bottomRightPosition, fromNode: sprite)
            let contactOffset = CGPoint(x: size.width / 2 - sprite.size.width, y: sprite.size.height)
            return (invaderMask, shieldOverlapPosition + contactOffset)
        default:
            return nil
        }
    }
    
    private class func physicsBodyForTexture(texture: SKTexture) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody.dynamic = true
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.categoryBitMask = PhysicsCategory.Shield.rawValue
        physicsBody.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody.contactTestBitMask = PhysicsCategory.AnyMissile.rawValue | PhysicsCategory.Invader.rawValue
        return physicsBody
    }
    
    private class func loadImage(named name: String) -> CGImageRef {
        let image = UIImage(named: name)
        return (image?.CGImage)!
    }
    
    /// Creates an image by masking a portion of the given `image`. The returned image will be the same size
    /// as the original image. The mask will only be applied to a rectangle of the same size as the `mask` 
    /// parameter using the given `maskOrigin`.
    ///
    /// - Parameter image: The source image to be masked.
    /// - Parameter mask: The image to use as a mask. The masked rectangle will be the same size as this image.
    /// - Parameter maskOrigin: The bottom right point of the masking rectangle.
    ///
    /// - Returns: A copy of the original image with the masked portion removed.
    
    private func maskedImage(image: CGImageRef, mask: CGImageRef, maskOrigin: CGPoint) -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(
            nil,
            CGImageGetWidth(image),
            CGImageGetHeight(image),
            8,
            0,
            colorSpace,
            CGImageGetAlphaInfo(image).rawValue)
        
        let imageSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))
        let imageRect = CGRect(origin: CGPointZero, size: imageSize)
        let imageMask = imageMaskWithImage(mask, size: imageSize, origin: maskOrigin)
        CGContextClipToMask(context, imageRect, imageMask)
        CGContextDrawImage(context, imageRect, image)
        
        return CGBitmapContextCreateImage(context)!
    }
    
    /// Creates an image mask that can be used to mask a small portion of a larger image.
    /// 
    /// - Parameter image: The image to use as the mask. It will be drawn at its own size at the `origin` point.
    /// - Parameter size: The size of the full image mask. This should be larger than `image`.
    /// - Parameter origin: The bottom right point of the actual mask within the full image.
    ///
    /// - Returns: An image mask.
    
    private func imageMaskWithImage(image: CGImageRef, size: CGSize, origin: CGPoint) -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(
            nil,
            Int(size.width),
            Int(size.height),
            8,
            0,
            colorSpace,
            CGImageGetAlphaInfo(image).rawValue)
        
        let imageSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))
        CGContextDrawImage(context, CGRect(origin: origin, size: imageSize), image)
        let fullImage = CGBitmapContextCreateImage(context)
        
        return CGImageMaskCreate(
            CGImageGetWidth(fullImage),
            CGImageGetHeight(fullImage),
            CGImageGetBitsPerComponent(fullImage),
            CGImageGetBitsPerPixel(fullImage),
            CGImageGetBytesPerRow(fullImage),
            CGImageGetDataProvider(fullImage),
            nil,
            false)!
    }
}