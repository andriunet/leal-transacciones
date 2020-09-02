//
//  LoadingImageView.swift
//  LoadingImageView
//
//  https://github.com/ggamecrazy/LoadingImageView


import UIKit
import QuartzCore

public enum LoadingImageState {
  case idle
  case downloading(URLSessionDownloadTask)
  case errored(URLSessionDownloadTask, NSError)
}

public final class LoadingImageView : UIView, URLSessionDownloadDelegate {
  
  public var state: LoadingImageState = .idle {
    didSet {
      updateUI()
      delegate?.loadingImageViewStateChanged(self, state: self.state)
      
      switch state {
      case .downloading(_):
        reloadImageView.removeFromSuperview()
        if let link = displayLink {
          link.isPaused = false
          link.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        }
      case .errored(_, _):
        if let link = displayLink {
          link.isPaused = true
        }
        progressLayer.isHidden = true
        addSubview(reloadImageView)
        if let image = delegate?.imageForReloadState(self) {
          reloadImage = image
        }
      case .idle:
        reloadImageView.removeFromSuperview()
        if let link = displayLink {
          link.isPaused = true
        }
      }
    }
  }
  
  public weak var delegate: LoadingImageViewDelegate?
  
  public var operationQueue : OperationQueue  = LoadingImageView.operationQueue
  
  public let imageView: UIImageView = UIImageView()
  
  public var tapGestureRecognizer: UITapGestureRecognizer {
    return UITapGestureRecognizer(target: self, action: #selector(LoadingImageView.tapOccured(_:)))
  }
    
  public var URLImagen: String = ""
  
  @IBInspectable public var inset: Float = 10.0
  
  @IBInspectable public var lineWidth: Float = 10.0
  
  @IBInspectable public var lineColor: UIColor = UIColor.gray
  
  @IBInspectable public var reloadImage: UIImage = UIImage() {
    didSet {
      self.reloadImageView.image = reloadImage
    }
  }
  
  public var progress: Float = 0.0
  
  fileprivate lazy var progressLayer: CAShapeLayer = {
    let shape = CAShapeLayer()
    shape.strokeStart = CGFloat(0.0)
    shape.strokeEnd = CGFloat(0.0)
    shape.fillColor = UIColor.clear.cgColor
    return shape
  }()
  
  fileprivate lazy var reloadImageView: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFit
    return image
  }()
  
  fileprivate lazy var displayLink: CADisplayLink? = {
    #if !TARGET_INTERFACE_BUILDER
    let link = CADisplayLink(target: self, selector: #selector(LoadingImageView.updateUI))
    link.preferredFramesPerSecond = 30 // twice every second
    return link
    #else
    return nil
    #endif
    }()

  
  fileprivate class var operationQueue : OperationQueue {
    struct Static {
      static let instance : OperationQueue = {
       let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.name = "LoadingImageViewQueue"
        return queue
      }()
    }
    return Static.instance
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  fileprivate func commonInit() {
    #if TARGET_INTERFACE_BUILDER
    backgroundColor = UIColor.red
    #else
    clipsToBounds = true
    backgroundColor = UIColor.white
    addGestureRecognizer(tapGestureRecognizer)
    
    backgroundColor = UIColor.clear
    
    addSubview(imageView)
    imageView.contentMode = contentMode
    imageView.isUserInteractionEnabled = true
    layer.addSublayer(progressLayer)
    #endif
  }
  
  //MARK: AutoLayout
  
  public override var intrinsicContentSize:CGSize {
   return imageView.intrinsicContentSize
  }
  
  //MARK: Lifecycle
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    imageView.frame = bounds
    reloadImageView.frame = bounds
  }
  
  override public func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    if let _ = superview {
      if let link = displayLink {
        link.isPaused = false

      }
    } else {
      if let link = displayLink {
        link.isPaused = true
      }
    }
  }
  
  //MARK: UI Sync
  @objc func updateUI() {
    DispatchQueue.main.async {
      self.updateProgressLayer(forState: self.state, progress: self.progress)
      
     // print("\(self.progress * 100)%")
    }
  }
  
  func updateProgressLayer(forState state: LoadingImageState, progress: Float) {
    switch state {
    case .downloading(_):
      progressLayer.isHidden = false
      progressLayer.path = UIBezierPath(semiCircleInRect: bounds, inset: CGFloat(inset)).cgPath
      progressLayer.strokeColor = lineColor.cgColor
      progressLayer.lineWidth = CGFloat(lineWidth)
      progressLayer.strokeEnd = max(CGFloat(progress), CGFloat(0.05))
    default:
      break
    }
  }
  
  //MARK: Network Calls
  public func downloadImage(_ URL: Foundation.URL, placeholder:UIImage?)->URLSessionDownloadTask {
    
    URLImagen = URL.absoluteString
    
    let config = URLSessionConfiguration.default
    let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    return downloadImage(URL, placeholder: placeholder, session: session)
  }
  
  public func downloadImage(_ URL: Foundation.URL, placeholder:UIImage?, session: Foundation.URLSession)->URLSessionDownloadTask {
    switch state {
    case .downloading(let task):
      task.cancel()
    default:
      break
    }
    
    self.imageView.image = placeholder ?? nil
    let request = NSMutableURLRequest(url: URL)
    request.timeoutInterval = 20.0
    let downloadTask = session.downloadTask(with: request as URLRequest)
    progress = 0.0
    state = .downloading(downloadTask)
    downloadTask.resume()
    return downloadTask
  }
  
  //MARK: - Actions
  
  @objc func tapOccured(_ sender: AnyObject) {
    switch state {
        
    case .errored(let task, _):
      let maybeAttemptReload = delegate?.shouldAttemptRetry(self)
      if let attemptReload = maybeAttemptReload {
        if attemptReload {
          _ = self.downloadImage(task.originalRequest!.url!, placeholder: nil)
        }
      } else {
        _ = self.downloadImage(task.originalRequest!.url!, placeholder: nil)
      }
      fallthrough
        
    default:
      #if DEBUG
        print("tap occured")
      #endif
      break
    }
  }
  
  deinit {
    if let link = displayLink {
      link.invalidate()
    }
  }
}

extension LoadingImageView {

  @objc(URLSession:task:didCompleteWithError:) public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    DispatchQueue.main.async {
      if let err = error {
        print("error: \(err)")
        self.state = .errored(task as! URLSessionDownloadTask, err as NSError)
      } else {
        self.progress = 1.0
        self.state = .idle
      }
    }
  }
  
  @objc(URLSession:downloadTask:didFinishDownloadingToURL:) public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    if let image = UIImage.decompressedImage(location) {
      DispatchQueue.main.async {
        if downloadTask.state == .canceling {
          return
        }
        let delay = 0.20
        let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
          self.progressLayer.isHidden = true
          self.imageView.image = image
          self.invalidateIntrinsicContentSize()
          let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
          fadeInAnimation.fromValue = 0.0
          fadeInAnimation.toValue = self.imageView.layer.opacity
          fadeInAnimation.duration = delay
          self.imageView.layer.add(fadeInAnimation, forKey: "fadeIn")
            
        }
        self.updateProgressLayer(forState: self.state, progress: 1.0)
        
      }
    } else {
      DispatchQueue.main.async {
        let err = NSError(domain: "Invalid Image", code: 400, userInfo: nil)
        self.state = .errored(downloadTask, err)
      }
    }
  }
  
  @objc(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:) public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    DispatchQueue.main.async {
      let progress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      self.progress = progress
    }
  }
}

public protocol LoadingImageViewDelegate : NSObjectProtocol {
  func loadingImageViewStateChanged(_ imageView: LoadingImageView, state: LoadingImageState)
  func shouldAttemptRetry(_ imageView: LoadingImageView)->Bool
  func imageForReloadState(_ imageView: LoadingImageView)->UIImage
}

extension UIImage {
  
  class func decompressedImage(_ imageURL: URL)->UIImage? {
    if let data = try? Data(contentsOf: imageURL) {
      if let image = UIImage(data: data) {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        let decompressedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return decompressedImage
      }
    }
    return nil
  }
}
