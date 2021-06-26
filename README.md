# Physiological-Signals-estimation-and-interative-Interface
## 生理參數互動介面 (MATLAB APP)

#### implement PTT-BP model
#### use ecg & ppg signals to calculate blood pressure value
-------------------------------------------------------------------------------------------------------------------

#### 程式開發與執行環境說明 
MATLAB(R2019b)


#### file structure:
```
this repo
├── clean data (data: raw_data.xlsx)
│   ├── 執行檔 1
│   ├── 執行檔 2
│   ├── app.mlapp
│   ├── app_MATLABcode.m
│   └── raw_data.xlsx
├── dirty data (data: bidmc_csv)
│   ├── app_bidmc.m
│   └── bidmc_csv
├── 程式說明書.pdf
```

#### 說明: 
#### **clean data file**

- 執行檔1 : 
  > 對**有 MATLAB(R2019b)** 的使用者，可在 MATLAB 裡 load 執行檔 1 裡 的 app.mlappinstall 此檔，
  > 有 load 成功後可再工具列 APPS-> MY APPS裡看到此 app(名稱 app)，按其圖示即可執行
  
- 執行檔2 : 
  > 對**無 MATLAB(R2019b)** 的使用者，在 for_redistribution 資料夾裡先安裝 MyAppInstaller_web 環境(第一次執行才需安裝)，
  > 接著在 for_redistribution_files_only 資料夾裡執行 app 檔即可。(但執行起來會較其他方式久)
  
- app.mlapp : 
  > MATLAB 程式碼 
  > 有MATLAB的使用者在 matlab command window 輸入 appdesigner 開啟此檔可看到當初設計及程式撰寫的介面

- app_MATLABcode.m : 
  > MATLAB 程式碼 
  > 有 MATLAB 的使用者直接run此檔也可執行app
  
- raw_data.xlsx : 
  > 原始資料

  
#### **dirty data file**
- app_bidmc.m : 
  > MATLAB 程式碼 
  > 有 MATLAB 的使用者直接run此檔也可執行app

- bidmc_csv : 
  > 原始資料，內有53筆資料，源自 BIDMC PPG and Respiration Dataset
  > 請使用 bidmc_編號_Signals.csv 來run code 
  > (default 建議使用 bidmc_02_Signals.csv來run)

  
-------------------------------------------------------------------------------------------------------------------
#### more details refer to 程式說明書.pdf
