import promptAction from '@ohos.promptAction'
import { AnswerStatus } from '../enums/AnswerStatus'
import { OptionStatus } from '../enums/OptionStatus'
import { PracticeStatus } from '../enums/PracticeStatus'
import { getRandomQuestion, Question } from '../modal/Question'

@Entry
@Component
struct PracticePage {
	@State currentIndex: number = 0;
	@State answerStatus: AnswerStatus = AnswerStatus.Answering;
	@State practiceStatus: PracticeStatus = PracticeStatus.Stopped;
	@State selectedOption: string = '';
	@State answeredCount: number = 0;
	@State rightCount: number = 0;
	@State totalCount: number = 10;
	@State questions: Question[] = getRandomQuestion(this.totalCount);
	timerController: TextTimerController = new TextTimerController();
	timeUsed: number = 0;

	startPractice() {
		this.practiceStatus = PracticeStatus.Running;
		this.timerController.start();
	}

	pausePractice() {
		this.practiceStatus = PracticeStatus.Paused;
		this.timerController.pause();
	}

	stopPractice() {
		this.practiceStatus = PracticeStatus.Stopped;
		this.timerController.pause();
	}

	build() {
		Column() {
			// 统计面板
			Column() {
				StateItem({
					name: '准确率',
					icon: $r('app.media.ic_accuracy'),
					fontColor: Color.Black,
				}) {
					Text((this.answeredCount === 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + '%')
						.width(100)
						.textAlign(TextAlign.Center)
				}

				StateItem({
					name: '进度',
					icon: $r('app.media.ic_progress'),
					fontColor: Color.Black,
				}) {
					Progress({ value: this.answeredCount, total: this.totalCount })
						.width(100)
				}

				StateItem({
					name: '个数',
					icon: $r('app.media.ic_count'),
					fontColor: Color.Black,
				}) {
					Button(this.totalCount.toString())
						.width(100)
						.height(25)
						.backgroundColor('#EBEBEB')
						.fontColor(Color.Black)
						.enabled(this.practiceStatus === PracticeStatus.Stopped)
						.onClick(() => {
							TextPickerDialog.show({
								range: ['5', '10', '15', '20'],
								value: this.totalCount.toString(),
								onAccept: (result) => {
									this.totalCount = parseInt(result.value)
									this.questions = getRandomQuestion(this.totalCount)
								}
							})
						})
				}

				StateItem({
					name: '用时',
					icon: $r('app.media.ic_timer'),
					fontColor: Color.Black,
				}) {
					Row() {
						TextTimer({ controller: this.timerController })
							.onTimer((utc: number, elapsedTime: number) => {
								this.timeUsed = elapsedTime
							})
					}
					.width(100)
					.justifyContent(FlexAlign.Center)
				}
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
					OptionButton({
						option,
						answerStatus: this.answerStatus,
						answer: this.questions[this.currentIndex].answer,
						selectedOption: this.selectedOption,
					})
						.enabled(this.answerStatus === AnswerStatus.Answering)
						.onClick(() => {
							// 判断练习状态
							if (this.practiceStatus !== PracticeStatus.Running) {
								return promptAction.showToast({
									message: '请先点击开始测试'
								})
							}

							// 判断正误
							this.selectedOption = option;

							// 统计信息
							this.answeredCount++;
							if (option === this.questions[this.currentIndex].answer) {
								this.rightCount++;
							}

							// 切换题目
							this.answerStatus = AnswerStatus.Answered
							if (this.currentIndex < this.questions.length - 1) {
								setTimeout(() => {
									this.currentIndex += 1;
									this.answerStatus = AnswerStatus.Answering;
								}, 500)
							} else {
								this.stopPractice();
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
						this.stopPractice();
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
							this.pausePractice();
						} else {
							this.startPractice();
						}
					})
			}
		}
		.practiceBgStyle();
	}
}

@Component
struct StateItem {
	name: string;
	icon: Resource;
	fontColor: Color;
	@BuilderParam statComp: () => void;

	onPageShow() {
		console.log('页面show');
	}

	aboutToAppear() {
		console.log('about');
	}

	build() {
		Row({ space: 10 }) {
			Image(this.icon)
				.width(14)
				.height(14)
			Text(this.name)
				.fontSize(14)
				.fontWeight(FontWeight.Medium)
				.fontColor(this.fontColor)
			Blank()
			this.statComp()
		}
		.width('100%')
		.height(30)
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
	option: string;
	answer: string;
	@State optionStatus: OptionStatus = OptionStatus.Default;
	// prop 先声明的先更新
	@Prop selectedOption: string;
	// 监听器
	@Prop @Watch('onAnswerStatusChange') answerStatus: AnswerStatus;

	onAnswerStatusChange() {
		console.log('监听器', this.answer)
		if (this.option === this.answer) {
			this.optionStatus = OptionStatus.Right;
		} else {
			if (this.option === this.selectedOption) {
				this.optionStatus = OptionStatus.Wrong;
			} else {
				this.optionStatus = OptionStatus.Default;
			}
		}
	}

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
