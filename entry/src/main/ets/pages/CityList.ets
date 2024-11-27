import { DataSource } from '../data/ServerDataSource';
import { Area } from '../Interfaces/Area'

@Entry
@Component
struct CityList {
  @State message: string = 'Hello World';
  @State httpCode: number = 0 // 定义一个状态变量用于保存 HTTP 响应码
  @State isHttpError: boolean = false
  @Prop allCityList: Area[] = [];
  @State cityTime: string = ''
  @State dataSet: MyDataSource = new MyDataSource()
  aboutToAppear(): void {
    const source = new DataSource()
    source.fetchHttpCode().then((code) => {
      this.httpCode = code; // 更新状态变量以触发 UI 的重新渲染
      if (code == 200) {
        DataSource.getAllTimeZone((data: Area[]) => {
          this.allCityList = data;
          //Push data into datasource
          for(let index = 0; index < data.length;index++){
            this.dataSet.pushData(data[index])
          }
        }, () => {
        })


        DataSource.getTimeZoneTime('Europe/Amsterdam',(time: string) => {
          console.log(`Time in Europe/Amsterdam: ${time}`);
          this.cityTime = time;
        },
          (err: Error) => {
            console.error('Error fetching time for Europe/Amsterdam:', err);
          })
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
            LazyForEach(this.dataSet, (item: Area) => {
              ListItem() {
                Text(`Timezone:${item.timezone}`)
              }
            }, (item: Area, index) => index + JSON.stringify(item))
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

// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: City[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): Area {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

export interface City {
  name: string;
  timezone: string;
  offset: number;
}


class MyDataSource extends BasicDataSource {
  private dataArray: Area[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): Area {
    return this.dataArray[index];
  }

  public addData(index: number, data: Area): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: Area): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}