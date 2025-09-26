class CustomButton: UIButton {
    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initColors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initColors()
    }
    
    func initColors() {
        layer.cornerRadius = frame.size.height / 2
        layer.masksToBounds = true
        setGradientBackground(colorOne: .blue, colorTwo: .red)
    }

    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        if let gradientLayer = self.gradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.gradientLayer = gradientLayer
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = self.bounds
    }
}
