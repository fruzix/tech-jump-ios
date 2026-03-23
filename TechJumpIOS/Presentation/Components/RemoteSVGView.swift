//
//  RemoteSVGView.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 06/03/2026.
//

import SwiftSVG
import SwiftUI

struct RemoteSVGView: UIViewRepresentable {
    let svgData: Data

    func makeUIView(context: Context) -> SVGHostingView {
        let view = SVGHostingView()
        view.backgroundColor = .blue
        view.render(data: svgData)
        return view
    }

    func updateUIView(_ uiView: SVGHostingView, context: Context) {
        uiView.render(data: svgData)
    }
}

final class SVGHostingView: UIView {
    private var svgLayer: SVGLayer?

    @MainActor
    func render(data: Data) {
        clearLayer()

        let svgUIView = UIView(svgData: data) { [weak self] layer in
            guard let self else { return }
            self.svgLayer = layer
            self.layer.addSublayer(layer)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    @MainActor
    private func clearLayer() {
        svgLayer?.removeFromSuperlayer()
        svgLayer = nil
        layer.sublayers?.removeAll(where: { $0 !== self.layer })
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let svgLayer else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        svgLayer.resizeToFit(bounds)

        CATransaction.commit()
    }
}
