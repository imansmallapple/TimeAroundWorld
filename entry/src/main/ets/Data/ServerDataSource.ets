import http from '@ohos.net.http';
import { Area, TimeZoneResponse, parseTimeZone } from '../Interfaces/Area'
import { City } from './DataSource';


// 服务器地址
// const ds_server: string = "";
// const ds_server: string = ""
// API Path
const api_timezone: string = "https://www.timeapi.io/api/timezone/availabletimezones";

class DataSource {
  public static allCityList: City[] = [];
  public static allCityTime: string[] = [];

  static getAllTimeZone(success: Function, error?: Function) {
    let httpRequest = http.createHttp();
    httpRequest.request(api_timezone, {
      method: http.RequestMethod.GET
    }, (err, data) => {
      if (!err && data.responseCode == 200) {
        // 将 JSON 字符串转为数组
        let dataArr = JSON.parse(data.result as string) as string[];
        dataArr.map((item) => {
          const parts = item.split("/");
          const name = parts[1] || parts[0];
          DataSource.allCityList.push({
            name: name,
            timezone: item,
          });
        });
        // 调用成功回调函数
        success(DataSource.allCityList, dataArr.length);
      } else {
        httpRequest.destroy();
      }
    });
  }

  static getTimeZoneTime(timezone: string, success: (time: string) => void, error?: (err: Error) => void) {
    let httpRequest = http.createHttp();
    let timezoneInfo = parseTimeZone(timezone)
    let api_timezone_time: string = `https://www.timeapi.io/api/time/current/zone?timeZone=${timezoneInfo.timezone}%2F${timezoneInfo.name}`

    httpRequest.request(api_timezone_time, {
      method: http.RequestMethod.GET
    }, (err, data) => {
      if (!err && data.responseCode == 200) {
        try {
          // Parse the JSON response as a TimeZoneResponse
          const response: TimeZoneResponse = JSON.parse(data.result as string);

          // Extract the `time` field
          const time = response.time;

          // Call the success callback with the extracted time
          success(time);
        } catch (parseError) {
          console.error("Error parsing response:", parseError);
          if (error) error(parseError as Error);
        }
      } else {
        console.error("HTTP request failed:", err);
        if (error) error(err as Error);
      }
    });
  }

  static getTimeZoneInfo(
    timezone: string,
    success: (info: TimeZoneResponse) => void,
    error?: (err: Error) => void
  ) {
    // Create the HTTP request object
    let httpRequest = http.createHttp();

    // Build the API URL
    const api_timezone_info: string = `https://www.timeapi.io/api/timezone/zone?timeZone=${encodeURIComponent(
      timezone
    )}`;

    // Send the HTTP GET request
    httpRequest.request(
      api_timezone_info,
      { method: http.RequestMethod.GET },
      (err, data) => {
        if (!err && data.responseCode === 200) {
          try {
            // Parse the JSON response into the TimeZoneResponse type
            const response: TimeZoneResponse = JSON.parse(data.result as string);

            // Call the success callback with the parsed response
            success(response);
          } catch (parseError) {
            console.error("Error parsing response:", parseError);
            if (error) error(parseError as Error);
          }
        } else {
          console.error("HTTP request failed:", err);
          if (error) error(err as Error);
        }
      }
    );
  }

  async fetchHttpCode(): Promise<number> {
    try {
      let httpRequest = http.createHttp();
      const response = await new Promise<number>((resolve, reject) => {
        httpRequest.request(api_timezone, (err: Error, data: http.HttpResponse) => {
          if (!err) {
            resolve(data.responseCode);
          } else {
            reject(err);
          }
        });
      });
      return response; // 返回响应码
    } catch (error) {
      console.error('Error fetching HTTP code:', error);
      return -1; // 返回一个错误码
    }
  }
}

export { DataSource, api_timezone }
