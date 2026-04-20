//
//  FlexibleTagLayout.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 20/04/2026.
//

import SwiftUI


struct FlexibleTagLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
	let data: Data
	let spacing: CGFloat
	let content: (Data.Element) -> Content

	init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
		self.data = data
		self.spacing = spacing
		self.content = content
	}

	var body: some View {
		GeometryReader { geometry in
			generateContent(in: geometry)
		}
		.frame(minHeight: 10)
	}

	private func generateContent(in geometry: GeometryProxy) -> some View {
		var width = CGFloat.zero
		var height = CGFloat.zero

		return ZStack(alignment: .topLeading) {
			ForEach(Array(data), id: \.self) { item in
				content(item)
					.padding(.trailing, spacing)
					.padding(.bottom, spacing)
					.alignmentGuide(.leading) { dimensions in
						if abs(width - dimensions.width) > geometry.size.width {
							width = 0
							height -= dimensions.height + spacing
						}

						let result = width
						if item == data.last {
							width = 0
						} else {
							width -= dimensions.width + spacing
						}
						return result
					}
					.alignmentGuide(.top) { _ in
						let result = height
						if item == data.last {
							height = 0
						}
						return result
					}
			}
		}
	}
}
