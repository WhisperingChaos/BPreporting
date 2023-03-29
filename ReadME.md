## Blood Pressure Reports
Provides a means to convert and perform an analysis of a CSV input file of blood pressure readings.  The analysis data is then converted into an output  CSV format that can be easily consumed by a google spreadsheet chart, such as a stacked bar chart, to depict the analytics.  
All reports conform to a general format.  This general format is explained by the [Reporting Framework](#reporting-framework) section. 
### Left Systolic Blood Pressure counts by Week
Show the percentage of Left Systolic daily blood pressure readings aggregrated by week according to [AMA blood pressure categories](https://targetbp.org/best-practices/guidelines17/).  The analytical output CSV format conforms to Google Sheet's vertically stacked bar chart.
#### input
Supplied as CSV formatted file as filepath named ```./input/BPdata.csv```.  This file should contain rows with the following column values:

**MeasurementDate,LeftSystolicReading**  
 + The names above represent column headings.  A column heading row is optional but if it appears, the column names should reflect the names above separated by commas.
 + **MeasurementDate** Should be format of _MM/DD/YYYY_ or _YYYY/MM/DD_.  There can be more than one blood pressure reading per day.
 + **LeftSystolicReading**  NNN is an integer representing systolic blood pressure.  It's assumed this measurement is in mm Hg.

Example:
```
MeasurementDate,LeftSystolicReading
01/01/2023,114
01/01/2023,124
01/02/2023,108
01/02/2023,120
```
#### etl process
To execute the transform 
  + start a terminal
  + navigate to the "Stacked_Bar_Graph_By_Week" subdirectory using: ```cd```
  + execute the following: ```> etl <InputToOutput.sql ```
#### output
The CSV generated by applying the **etl** function conforms to Google Sheet's stacked bar chart.  The CSV is stored to the filepath: ```./output/BPreport.csv```

**WeekSinceAnchor,Low,NormalLower,Normal,ElevatedLower,Elevated,Stage1Lower,Stage1,Stage2Lower,Stage2,Stage2High**
  + **WeekSinceAnchor**  Is an integer ordinal relative to the distance in weeks from the anchor week.  The anchor week is defined as the date of the oldest MeasurementDate appearing in the input data.  A WeekSinceAnchor value of zero "0" indicates that the blood pressure measurement was within the first 6 days of the anchor week's date while a value of one "1" aggregates daily readings 7 to 13 days from the anchor. 

    This column's values appear as the x-axis values displayed by a stacked bar chart.

The remaining columns are aggregrate counts of a week's worth of left systolic measurements whose value falls within the range of the reading implied by the column name.
| Column Name  |  Systolic Range |
| :------------ | :-------------: |
| **Low**  | Systoltic < 90  |
| **NormalLower** | 90 =< Systolic =< 110 |
| **Normal**  | 111 =< Systolic =< 119 |
| **ElevatedLower** | 120 =< Systolic =< 124 |
| **Elevated** | 125 =< Systolic =< 129  |
|**Stage1Lower** | 130 =< Systolic =< 134 |
|**Stage1** | 135 =< Systolic =< 139 |
|**Stage2Lower** | 140 =< Systolic =< 144 |
|**Stage2** | 145 =< Systolic =< 149 |
|**Stage2High**| 150 =< Systolic |

These columns become the "series" data that's stacked on top of one another to create a vertical bar.  They are stacked in left to right order where  **Low** is the bottom most layer of the vertical bar while **Stage2High** sits on the bar's top.
 
Example CSV output:
```
WeekSinceAnchor,Low,NormalLower,Normal,ElevatedLower,Elevated,Stage1Lower,Stage1,Stage2Lower,Stage2,Stage2High  
0,,2,3,3,4,1,,,  
1,,2,4,4,3,1,,,,  
2,,3,7,1,1,1,,,,  
3,,6,7,2,1,,,,,  
4,,7,6,1,,,,,,  
5,,1,1,,,,,,,  
```
### Reporting Framework
Every report has same abstract format:
  + input 
  + etl process
  + output
#### input
Supplies the blood pressure readings in an CSV formated file expected by the report's stated input.
  + The CSV formated input file must be saved to the "input" subdirectory of the specific report's parent directory.
  + The file must be named BPdata.csv
  + The file's CSV format must conform to the desired input reporting format.
#### etl process
The transform process that converts the BPData into a form needed by either the next step in the etl process or the desired final output format.  For example, the report [Left Systolic Blood Pressure counts by Week](#left-systolic-blood-pressure-counts-by-week) converts its BPdata.csv file into an output CSV file that can easily be consumed by Google Sheet's Graph tool to quickly generate a stacked bar chart.
The etl process employs SQL to program its transforms.  Use SQL VIEWs to create a layered set of transforms to encode the desired conversion from input to output.  One could also create a transform pipeline by feeding the
output of one etl process to into the input of another one. 
#### output
The CSV report generated by appling the etl process to the report's inputs.
  + The etl process must write the report CSV to the "output" subdirectory of the specific report's parent directory.
  + The file must be named "BPreport.csv"
  + The file CSV format must conform to the desired output reporting format.
