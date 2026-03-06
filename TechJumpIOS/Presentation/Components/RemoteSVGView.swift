//
//  RemoteSVGView.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 06/03/2026.
//

import SwiftSVG
import SwiftUI

struct SVGDataView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> SVGHostingView {
        let view = SVGHostingView()
        view.backgroundColor = .blue
        view.load(urlString: urlString)
        return view
    }

    func updateUIView(_ uiView: SVGHostingView, context: Context) {
        uiView.load(urlString: urlString)
    }
}

final class SVGHostingView: UIView {
    private var currentURLString: String?
    private var loadTask: Task<Void, Never>?
    private var svgLayer: SVGLayer?

    deinit {
        loadTask?.cancel()
    }

    func load(urlString: String) {
        guard currentURLString != urlString else { return }
        currentURLString = urlString

        loadTask?.cancel()
        clearLayer()

        guard let url = URL(string: urlString) else { return }

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard !Task.isCancelled else { return }

                if let http = response as? HTTPURLResponse,
                   !(200 ..< 300).contains(http.statusCode)
                {
                    return
                }

                await MainActor.run {
                    self.render(data: data)
                }
            } catch {
                // ignore or log if needed
            }
        }
    }

    @MainActor
    private func render(data: Data) {
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
