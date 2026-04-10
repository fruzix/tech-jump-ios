//
//  SVGView.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 23/03/2026.
//

import Combine
import SwiftSVG
import SwiftUI

struct SVGView: View {
    private let svgURL: String
    private let pokemonId: Int
    @Environment(\.injected) var injected: DIContainer
    @State private var svg: Loadable<Data>

    init(svgURL: String, pokemonId: Int, svg: Loadable<Data> = .notRequested) {
        self.svgURL = svgURL
        self.pokemonId = pokemonId
        self._svg = .init(initialValue: svg)
    }

    var body: some View {
        content
    }

    @ViewBuilder private var content: some View {
        switch svg {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case let .loaded(svg):
            loadedView(svg)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension SVGView {
    func loadSvg() {
        injected.interactors.svg
            .load(data: $svg, url: svgURL, pokemonId: pokemonId)
    }
}

// MARK: - Content

private extension SVGView {
    func defaultView() -> some View {
        Text("").onAppear {
            self.loadSvg()
        }
    }

    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(.circular)
    }

    func failedView(_: Error) -> some View {
        Text("Unable to load svg")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding()
    }

    func loadedView(_ data: Data) -> some View {
        SVGRenderView(svgData: data)
    }
}

struct SVGRenderView: UIViewRepresentable {
    let svgData: Data

    func makeUIView(context: Context) -> SVGHostingView {
        let view = SVGHostingView()
        view.backgroundColor = .clear
        view.render(data: svgData)
        return view
    }

    func updateUIView(_ uiView: SVGHostingView, context: Context) {
        uiView.renderIfNeeded(data: svgData)
    }
}

final class SVGHostingView: UIView {
    private var svgLayer: SVGLayer?
    private var renderedData: Data?

    @MainActor
    func renderIfNeeded(data: Data) {
        guard data != renderedData else { return }
        render(data: data)
    }

    @MainActor
    func render(data: Data) {
        renderedData = data
        clearLayer()

        _ = UIView(svgData: data) { [weak self] layer in
            DispatchQueue.main.async {
                guard let self else { return }
                self.svgLayer = layer
                self.layer.addSublayer(layer)
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
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

#Preview {
    VStack {
        SVGView(svgURL: "", pokemonId: 0)
        SVGView(svgURL: "", pokemonId: 0)
        SVGView(svgURL: "", pokemonId: 0)
    }
}
