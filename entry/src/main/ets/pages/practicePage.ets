@Entry
@Component
struct PracticePage {
	build() {
		Column() {
			// 统计面板
			Column() {
				Text("test")
				Text("test")
				Text("test")
				Text("test")
			}
			.stateBgStyle()

			// 题目
			Column() {
				Text("单词")
					.wordStyle()
				Text("例句")
					.sentenceStyle()
			}
			// 选项
			Column({ space: 10 }) {
				ForEach([1, 2, 3, 4], option => {
					Button(option.toString())
						.optionButtonStyle({
							bg: Color.White,
							font: Color.Black
						})
				})
			}
			// 控制面板
			Row({ space: 50 }) {
				Button("停止测试")
					.controlButtonStyle({
						bg: Color.Transparent,
						font: Color.Black,
						border: Color.Black
					})
				Button("开始测试")
					.controlButtonStyle({
						bg: Color.Black,
						font: Color.White,
						border: Color.Black
					})
			}
		}
		.practiceBgStyle()
	}
}

@Extend(Column) function practiceBgStyle() {
	.width("100%")
	.height("100%")
	.backgroundImage($r("app.media.img_practice_bg"))
	.backgroundImageSize({ width: "100%", height: "100%" })
	.justifyContent(FlexAlign.SpaceEvenly)
}

@Styles function stateBgStyle() {
	.width("90%")
	.padding(20)
	.borderRadius(10)
	.backgroundColor(Color.White)
}

@Extend(Text) function wordStyle() {
	.fontSize(50)
	.fontWeight(FontWeight.Bold)
}

@Extend(Text) function sentenceStyle() {
	.width("80%")
	.height(40)
	.fontSize(16)
	.fontColor("#9BA1A5")
	.fontWeight(FontWeight.Medium)
	.textAlign(TextAlign.Center)
}

@Extend(Button) function optionButtonStyle(color: {
	bg: ResourceColor,
	font: ResourceColor
}) {
	.width(240)
	.height(48)
	.fontSize(16)
	.fontColor(color.font)
	.fontWeight(FontWeight.Medium)
	.backgroundColor(color.bg)
	.type(ButtonType.Normal)
	.borderRadius(8)
}

@Extend(Button) function controlButtonStyle(color: {
	bg: ResourceColor,
	font: ResourceColor,
	border: ResourceColor
}) {
	.fontSize(16)
	.fontColor(color.font)
	.borderWidth(1)
	.borderColor(color.border)
	.backgroundColor(color.bg)
}
