import promptAction from '@ohos.promptAction'
import { AnswerStatus } from '../enums/AnswerStatus'
import { OptionStatus } from '../enums/OptionStatus'
import { PracticeStatus } from '../enums/PracticeStatus'
import { getRandomQuestion, Question } from '../modal/Question'

@Entry
@Component
struct PracticePage {
	@State currentIndex: number = 0
	@State questions: Question[] = getRandomQuestion(10)
	@State answerStatus: AnswerStatus = AnswerStatus.Answering
	@State practiceStatus: PracticeStatus = PracticeStatus.Stopped

	startPractice() {
		this.practiceStatus = PracticeStatus.Running;
	}

	pausePractice() {
		this.practiceStatus = PracticeStatus.Paused;
	}

	stopPractice() {
		this.practiceStatus = PracticeStatus.Stopped;
	}

	build() {
		Column() {
			// 统计面板
			Column() {
				Text('test')
				Text('test')
				Text('test')
				Text('test')
			}
			.stateBgStyle()

			// 题目
			Column() {
				Text(this.questions[this.currentIndex].word)
					.wordStyle()
				Text(this.questions[this.currentIndex].sentence)
					.sentenceStyle()
			}
			// 选项
			Column({ space: 10 }) {
				ForEach(this.questions[this.currentIndex].options, (option) => {
					OptionButton({ option })
						.enabled(this.answerStatus === AnswerStatus.Answering)
						.onClick(() => {
							// 判断练习状态
							if (this.practiceStatus !== PracticeStatus.Running) {
								return promptAction.showToast({
									message: '请先点击开始测试'
								})
							}
							this.answerStatus = AnswerStatus.Answered
							if (this.currentIndex < this.questions.length - 1) {
								setTimeout(() => {
									this.currentIndex += 1
									this.answerStatus = AnswerStatus.Answering
								}, 500)
							} else {
								this.stopPractice()
							}
						})
					// 设置ForEach的keyGenerator
				}, (option) => this.questions[this.currentIndex].word + '-' + option)
			}
			// 控制面板
			Row({ space: 50 }) {
				Button('停止测试')
					.controlButtonStyle({
						bg: Color.Transparent,
						font: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black,
						border: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black,
					})
					.enabled(this.practiceStatus != PracticeStatus.Stopped)
					.onClick(() => {
						this.stopPractice()
					})
				Button(this.practiceStatus === PracticeStatus.Running ? '暂停测试' : '开始测试')
					.controlButtonStyle({
						bg: this.practiceStatus === PracticeStatus.Running ? '#555555' : Color.Black,
						font: Color.White,
						border: this.practiceStatus === PracticeStatus.Running ? '#555555' : Color.Black,
					})
					.stateEffect(false) // stateEffect属性设置Button是否开启点击效果
					.onClick(() => {
						if (this.practiceStatus === PracticeStatus.Running) {
							this.pausePractice()
						} else {
							this.startPractice()
						}
					})
			}
		}
		.practiceBgStyle()
	}
}

@Extend(Column) function practiceBgStyle() {
	.width('100%')
	.height('100%')
	.backgroundImage($r('app.media.img_practice_bg'))
	.backgroundImageSize({ width: '100%', height: '100%' })
	.justifyContent(FlexAlign.SpaceEvenly)
}

@Styles function stateBgStyle() {
	.width('90%')
	.padding(20)
	.borderRadius(10)
	.backgroundColor(Color.White)
}

@Extend(Text) function wordStyle() {
	.fontSize(50)
	.fontWeight(FontWeight.Bold)
}

@Extend(Text) function sentenceStyle() {
	.width('80%')
	.height(40)
	.fontSize(16)
	.fontColor('#9BA1A5')
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

// 自定义选项按钮组件
@Component
struct OptionButton {
	option: string
	@State optionStatus: OptionStatus = OptionStatus.Default

	getBgColor() {
		switch (this.optionStatus) {
			case OptionStatus.Right:
				return '#1DBF7B'
			case OptionStatus.Wrong:
				return '#FA635F'
			default:
				return Color.White
		}
	}

	build() {
		Stack() {
			Button(this.option)
				.optionButtonStyle({
					bg: this.getBgColor(),
					font: this.optionStatus === OptionStatus.Default ? Color.Black : Color.White
				})
			if (this.optionStatus === OptionStatus.Right) {
				Image($r('app.media.ic_right'))
					.width(22)
					.height(22)
					.offset({ x: 10 })
			} else if (this.optionStatus === OptionStatus.Wrong) {
				Image($r('app.media.ic_wrong'))
					.width(22)
					.height(22)
					.offset({ x: 10 })
			}
		}
		.alignContent(Alignment.Start)
	}
}
