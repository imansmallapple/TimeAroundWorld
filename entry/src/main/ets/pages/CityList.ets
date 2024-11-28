import { City } from '../Data/DataSource';
import { DataSource } from '../data/ServerDataSource';
import { TimeZoneResponse } from '../Interfaces/Area'

@Entry
@Component
struct CityList {
  @State message: string = 'Hello World';
  @State httpCode: number = 0 // 定义一个状态变量用于保存 HTTP 响应码
  @State isHttpError: boolean = false
  @State allCityList: City[] = [];
  @State cityTime: string = ''
  @State offsetList: string[] = []

  aboutToAppear(): void {
    const source = new DataSource()
    source.fetchHttpCode().then((code) => {
      this.httpCode = code; // 更新状态变量以触发 UI 的重新渲染
      if (code == 200) {
        DataSource.getAllTimeZone((data: City[]) => {
          this.allCityList = data;
        }, () => {
        })

        DataSource.getTimeZoneTime('Europe/Amsterdam', (time: string) => {
          console.log(`Time in Europe/Amsterdam: ${time}`);
          this.cityTime = time;
        },
          (err: Error) => {
            console.error('Error fetching time for Europe/Amsterdam:', err);
          })

        DataSource.getTimeZoneInfo(
          "Europe/Amsterdam",
          (info) => {
            console.log("Time Zone Info:", info);
            console.log("Current Local Time:", info.year);
          },
          (err) => {
            console.error("Failed to fetch time zone info:", err);
          }
        );
      }
    });
  }

  build() {
    Stack() {
      Text(`Time:${this.cityTime}`)
      if (this.httpCode == -1) {
        HttpErrorComponent({
          text: 'Can\'t connect to the server'
        })
      }
      else if (this.httpCode == 200) {
        HttpErrorComponent({
          text: 'Working!'
        })
      }

      Scroll() {
        Column() {
          List({ space: 0, initialIndex: 0 }) {
            ForEach(this.allCityList, (item: City) => {
              ListItem() {
                Text(`Timezone:${item.timezone}`)
              }
            }, (item: City, index) => index + JSON.stringify(item))
          }
          .width('auto')
          .height('auto')
          .padding({ left: 15, right: 15 })
          .divider({
            strokeWidth: 0.5,
            color: '#d6d6d6',
            startMargin: 65,
            endMargin: 0
          })
        }
        .width('100%')

        //          .margin({top: 7.5, bottom: 7.5})
      }
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('auto')
      .margin({ bottom: 56 })
    }
    .height('100%')
  }
}

@Component
export struct HttpErrorComponent {
  @Prop text: string = ''

  build() {
    Column() {
      Column() {

        Text(this.text)
          .opacity(0.4)
          .margin(5)
      }
      .margin({
        bottom: '10%'
      })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}