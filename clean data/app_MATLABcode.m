classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        LoaddataTab                     matlab.ui.container.Tab
        DataManagementPanel             matlab.ui.container.Panel
        LoadButton                      matlab.ui.control.Button
        DataViewerPanel                 matlab.ui.container.Panel
        FilePathEditFieldLabel          matlab.ui.control.Label
        FilePathEditField               matlab.ui.control.EditField
        UITable                         matlab.ui.control.Table
        PlotECGPPGSignalTab             matlab.ui.container.Tab
        Panel                           matlab.ui.container.Panel
        LoadRawSignalButton             matlab.ui.control.Button
        FindPeakButton                  matlab.ui.control.Button
        ScaleButton                     matlab.ui.control.Button
        Panel_2                         matlab.ui.container.Panel
        Panel_5                         matlab.ui.container.Panel
        UIAxes_raw_sig                  matlab.ui.control.UIAxes
        PlotPTTTab                      matlab.ui.container.Tab
        PTTPanel                        matlab.ui.container.Panel
        PlotPTT                         matlab.ui.control.Button
        meanPTTEditFieldLabel           matlab.ui.control.Label
        meanPTTEditField                matlab.ui.control.NumericEditField
        sLabel                          matlab.ui.control.Label
        ResultViewerPanel_2             matlab.ui.container.Panel
        UIAxes_PTT                      matlab.ui.control.UIAxes
        PlotBPTab                       matlab.ui.container.Tab
        BPPanel                         matlab.ui.container.Panel
        HeightEditFieldLabel            matlab.ui.control.Label
        HeightEditField                 matlab.ui.control.NumericEditField
        PlotBP                          matlab.ui.control.Button
        SystolicBloodPressureLabel      matlab.ui.control.Label
        SystolicBloodPressureEditField  matlab.ui.control.NumericEditField
        MeanBloodPressureLabel          matlab.ui.control.Label
        MeanBloodPressureEditField      matlab.ui.control.NumericEditField
        DiastolicBloodPressureLabel     matlab.ui.control.Label
        DiastolicBloodPressureEditField  matlab.ui.control.NumericEditField
        pleaseenterheightbelowLabel     matlab.ui.control.Label
        mLabel                          matlab.ui.control.Label
        mmHgLabel                       matlab.ui.control.Label
        mmHgLabel_4                     matlab.ui.control.Label
        mmHgLabel_5                     matlab.ui.control.Label
        Lamp_DBP                        matlab.ui.control.Lamp
        Lamp_SBP                        matlab.ui.control.Lamp
        ResultViewerPanel               matlab.ui.container.Panel
        UIAxes_BP                       matlab.ui.control.UIAxes
        PlotHRVTab                      matlab.ui.container.Tab
        HRVPanel                        matlab.ui.container.Panel
        PlotHRV                         matlab.ui.control.Button
        MeanHeartRateEditFieldLabel     matlab.ui.control.Label
        Lamp_HR                         matlab.ui.control.Lamp
        MeanHeartRateEditField          matlab.ui.control.NumericEditField
        beatsminLabel                   matlab.ui.control.Label
        ResultViewerPanel_4             matlab.ui.container.Panel
        UIAxes_HRV                      matlab.ui.control.UIAxes
        PlotPRVTab                      matlab.ui.container.Tab
        Lamp_PR                         matlab.ui.control.Lamp
        PRVPanel                        matlab.ui.container.Panel
        PlotPRV                         matlab.ui.control.Button
        MeanPulseRateEditFieldLabel     matlab.ui.control.Label
        MeanPulseRateEditField          matlab.ui.control.NumericEditField
        beatsminLabel_2                 matlab.ui.control.Label
        ResultViewerPanel_3             matlab.ui.container.Panel
        UIAxes_PRV                      matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        % set up private properties(variables) to be shared within an app
        load_data = 0, load_raw_sig = 0, set_height = 0, findpeak = 0   % initial state of different condition
        height
        ecg
        ppg
        SF = 1000   % data sample frequency 1000 Hz
        t           % time (data recored time)
        ecg_pos, ecg_val, ppg_pos, ppg_val
        ptt = 0.0   % set up pulse transit time(PTT) initial value
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            [filename, filepath] = uigetfile('*.*','please select a file to import');
            if filename
                app.FilePathEditField.Value = [filepath, filename];
                data = readtable([filepath, filename]);     % read data from file
                app.load_data = 1;                          % load_date state = true
                
                %% show data on app.UITable
                app.UITable.Data = data; 
                app.UITable.ColumnName = data.Properties.VariableNames;
                app.UITable.FontSize = 14;                  
            end
        end

        % Value changed function: HeightEditField
        function HeightEditFieldValueChanged(app, event)
            app.height = app.HeightEditField.Value;     % set up height by user enter's value
            app.set_height = 1;                         % change set height state to '1'
        end

        % Button pushed function: LoadRawSignalButton
        function LoadRawSignalButtonPushed(app, event)
            % error detection
            if app.load_data == 0       % if haven't load data, show error message
                errordlg('please load data first !')
                return
            end
            
            app.ecg = table2array(app.UITable.Data(:,1));
            app.ppg = table2array(app.UITable.Data(:,2)); 
            app.ecg = rescale(app.ecg, 0, 1);   % ecg data normalization
            app.ppg = rescale(app.ppg, 0, 1);   % ppg data normalization
            app.load_raw_sig = 1;
            app.t = 0:1/app.SF:2*60-1/app.SF;   % set X_axes = 2min(120s)
            
            %% plot result on app.UIAxes_raw_sig
            plot(app.UIAxes_raw_sig,0)
            hold(app.UIAxes_raw_sig,'on')
            p(1) = plot(app.UIAxes_raw_sig,app.t,app.ecg,'r');
            p(2) = plot(app.UIAxes_raw_sig,app.t,app.ppg,'color', '#0072BD');   
            legend(app.UIAxes_raw_sig, p ,{'ecg','ppg'},'FontSize',9);    
            
            app.UIAxes_raw_sig.Title.String = 'raw signal';
            app.UIAxes_raw_sig.YLabel.String = '';
            app.UIAxes_raw_sig.XLabel.String = 'time (s)';
            app.UIAxes_raw_sig.YLim = [-0.5 1.5];
            hold(app.UIAxes_raw_sig,'off');
            close(gcf);
        end

        % Button pushed function: FindPeakButton
        function FindPeakButtonPushed(app, event)
            %% error detection
            if app.load_data == 0       % if haven't load data, show error message
                errordlg('please load data first !')   
                return
            end           
            if app.load_raw_sig == 0    % if haven't load raw signal, show error message
                errordlg('please load raw signal first !')
                return  
            end
             
            
            %% peak detection of ECG
            j=1;
            n = size(app.ecg);
            val = [];
            pos = [];
            for i=2:n-1
                if app.ecg(i)> app.ecg(i-1) && app.ecg(i)>= app.ecg(i+1) && app.ecg(i)> 0.7*max(app.ecg)    %threshold : 0.7*max(app.ecg)
                   val(j)= app.ecg(i);  % the jth peak value
                   pos(j)=i;            % the jth peak location
                   j=j+1;
                 end
            end
            app.ecg_pos = pos./app.SF;     
            app.ecg_val = val;   
            
            
            %% peak detection of PPG
            m=1;
            n=size(app.ppg);
            pos1 = [];
            val1 = [];
            for i=2:n-1
                if app.ppg(i)> app.ppg(i-1) && app.ppg(i)>= app.ppg(i+1) && app.ppg(i)> 0.5*max(app.ppg)  %threshold : 0.5*max(app.ppg)
                   val1(m)= app.ppg(i);
                   pos1(m)=i;
                   m=m+1;
                 end
            end
            app.ppg_pos=pos1(2:end)./app.SF;  %(2:end) because physiologically, pulse signal is lagging after the corresponding heart signal            
            app.ppg_val=val1(2:end); 
            app.findpeak = 1;
            
            
            %% plot result on app.UIAxes_raw_sig
            plot(app.UIAxes_raw_sig,0)
            hold(app.UIAxes_raw_sig,'on')
            p(1) = plot(app.UIAxes_raw_sig,app.t,app.ecg,'r');
            p(2) = plot(app.UIAxes_raw_sig,app.t,app.ppg,'color', '#0072BD');   
            p(3) = plot(app.UIAxes_raw_sig,app.ecg_pos,app.ecg_val,'*k'); 
            p(4) = plot(app.UIAxes_raw_sig,app.ppg_pos,app.ppg_val,'*g');     
            legend(app.UIAxes_raw_sig,p,{'ecg','ppg','ecg peak','ppg peak'},'FontSize',8);
            
            app.UIAxes_raw_sig.Title.String = 'raw signal + peak point';
            app.UIAxes_raw_sig.YLabel.String = '';
            app.UIAxes_raw_sig.XLabel.String = 'time (s)';
            app.UIAxes_raw_sig.XLim = [0 120];
            app.UIAxes_raw_sig.YLim = [-0.5 1.5];
            hold(app.UIAxes_raw_sig,'off');
            close(gcf);
        end

        % Button pushed function: ScaleButton
        function ScaleButtonPushed(app, event)
            %% error detection
            if app.load_data == 0 
                errordlg('please load data first !')
                return
            end           
            if app.load_raw_sig == 0
                errordlg('please load raw signal first !')
                return  
            end
            if app.findpeak == 0
                errordlg('please findpeak first !')
                return  
            end
            
            
            %% calculate ecg_pos_scale & ecg_pos_val_scale in range 50~60 sec
            j = 1;
            ecg_pos_scale = [];
            ecg_pos_val_scale = [];
            for i = 1:length(app.ecg_pos)
                if app.ecg_pos(i) >= 50 && app.ecg_pos(i) <= 60
                    ecg_pos_scale(j) = app.ecg_pos(i);
                    ecg_pos_val_scale(j) = app.ecg_val(i);
                    j = j + 1;
                end
            end
            
            
            %% calculate ppg_pos_scale & ppg_pos_val_scale in range 50~60 sec
            j = 1;
            ppg_pos_scale = [];
            ppg_pos_val_scale = [];
            for i = 1:length(app.ppg_pos)
                if app.ppg_pos(i) >= 50 && app.ppg_pos(i) <= 60
                    ppg_pos_scale(j) = app.ppg_pos(i);
                    ppg_pos_val_scale(j) = app.ppg_val(i);
                    j = j + 1;
                end
            end
            
            
            %% plot result on app.UIAxes_raw_sig (only show range 50~60 sec)
            plot(app.UIAxes_raw_sig,0)
            hold(app.UIAxes_raw_sig,'on')
            p(1) = plot(app.UIAxes_raw_sig,app.t(50*app.SF:60*app.SF),app.ecg(50*app.SF:60*app.SF),'r');
            p(2) = plot(app.UIAxes_raw_sig,app.t(50*app.SF:60*app.SF),app.ppg(50*app.SF:60*app.SF),'color', '#0072BD');   
            p(3) = plot(app.UIAxes_raw_sig,ecg_pos_scale,ecg_pos_val_scale,'*k');
            p(4) = plot(app.UIAxes_raw_sig,ppg_pos_scale,ppg_pos_val_scale,'*g'); 
            legend(app.UIAxes_raw_sig,p,{'ecg','ppg','ecg peak','ppg peak'},'FontSize',8);  
            
            app.UIAxes_raw_sig.Title.String = 'raw signal + peak point  + scale';
            app.UIAxes_raw_sig.YLabel.String = '';
            app.UIAxes_raw_sig.XLabel.String = 'time(s)';
            app.UIAxes_raw_sig.XLim = [50 60];
            app.UIAxes_raw_sig.YLim = [-0.5 1.5];
            hold(app.UIAxes_raw_sig,'off');
            close(gcf);
        end

        % Button pushed function: PlotPTT
        function PlotPTTPushed(app, event)
            %% error detection
            if app.load_data == 0 
                errordlg('please load data first !')
                return
            end           
            if app.load_raw_sig == 0
                errordlg('please load raw signal first !')
                return  
            end
            if app.findpeak == 0
                errordlg('please findpeak first !')
                return  
            end 
            
            
            %% calculate PTT (Pulse Transit Time) (use app.ppg_pos and app.ecg_pos properties)
            app.ptt = app.ppg_pos-app.ecg_pos; 
            
            
            %% plot result on app.UIAxes_PTT
            plot(app.UIAxes_PTT,0)
            hold(app.UIAxes_PTT,'on')
            stairs(app.UIAxes_PTT, app.ptt,'linewidth',1 ,'Color', '#0072BD');
            legend(app.UIAxes_PTT,'Pulse Transit Time (PTT)','FontSize',9);
            
            app.UIAxes_PTT.XLabel.String = 'time (s)';
            app.UIAxes_PTT.YLabel.String = 'PTT (s)';
            app.UIAxes_PTT.XLim = [0 120];
            app.UIAxes_PTT.YLim = [0.3 0.4];
            hold(app.UIAxes_PTT,'off');
            close(gcf);
            
            
            %% show mean PTT value on app.meanPTTEditField(a text edit field)
            app.meanPTTEditField.Value = sum(app.ptt)/length(app.ptt);
        end

        % Button pushed function: PlotBP
        function PlotBPPushed(app, event)
            %% error detection
            if app.load_data == 0 
                errordlg('please load data first !')
                return
            end           
            if app.load_raw_sig == 0
                errordlg('please load raw signal first !')
                return  
            end
            if app.findpeak == 0
                errordlg('please findpeak first !')
                return  
            end 
            if app.ptt == 0.0
                errordlg('please calculate and plot PTT first !')
                return
            end
            if app.set_height == 0
                errordlg('please enter height first !')
                return
            end
                        
            
            %% calculate Blood Pressure (use app.height and app.ptt properties)
            MBP = 1.947*(app.height^2)./(app.ptt.^2) + 31.84*app.height;
            SBP = 1.3*MBP +1.5;
            DBP = 0.83*MBP-0.7;
            
            
            %% plot result on app.UIAxes_BP
            plot(app.UIAxes_BP,0)
            hold(app.UIAxes_BP,'on')
            s(1) = stairs(app.UIAxes_BP,SBP,'linewidth',1); 
            s(2) = stairs(app.UIAxes_BP,MBP,'linewidth',1);        
            s(3) = stairs(app.UIAxes_BP,DBP,'linewidth',1);
            legend(app.UIAxes_BP,s,{'SBP signal','MBP signal','DBP signal'},'FontSize',8, 'Location','south','Orientation','horizontal');
            
            app.UIAxes_BP.XLabel.String = 'time (s)';
            app.UIAxes_BP.YLabel.String = 'BP(mmHg)';
            app.UIAxes_BP.YLim = [0 120];
            app.UIAxes_BP.YLim = [70 140];
            hold(app.UIAxes_BP,'off');
            close(gcf);
            
            
            %% show mean blood pressure value on BloodPressureEditField separately
            app.SystolicBloodPressureEditField.Value = sum(SBP)/length(SBP);
            app.MeanBloodPressureEditField.Value = sum(MBP)/length(MBP);
            app.DiastolicBloodPressureEditField.Value = sum(DBP)/length(DBP);
            
            
            %% determine if the systolic blood pressure value in healthy range
            if app.SystolicBloodPressureEditField.Value >= 140
                app.Lamp_SBP.Color = 'red';     % not in normal range : red light
            else
                app.Lamp_SBP.Color = 'green';   % in normal range : green light
            end
            
            
            %% determine if the diastolic blood pressure value in healthy range
            if app.DiastolicBloodPressureEditField.Value >= 90
                app.Lamp_DBP.Color = 'red';     % not in normal range : red light
            else
                app.Lamp_DBP.Color = 'green';   % in normal range : green light
            end
        end

        % Button pushed function: PlotHRV
        function PlotHRVPushed(app, event)
            %% error detection
           if app.load_data == 0 
                errordlg('please load data first !')
                return
            end           
            if app.load_raw_sig == 0
                errordlg('please load raw signal first !')
                return  
            end
            if app.findpeak == 0
                errordlg('please findpeak first !')
                return  
            end 
            
            
            %% calculate Heart Rate Variability (use app.ecg_pos property)
            j=1;
            n = length(app.ecg_pos);
            e = [];
            for i = 1:n-1       
                e(i)= app.ecg_pos(i+1)-app.ecg_pos(i); % gives RR interval
            end 
            hr = 60./mean(e);  % 60/ mean of heart rate RR interval (beats/min)
            hrv= 60./e;        % 60/ each heart rate RR interval    (beats/min)
            
            
             %% plot result on app.UIAxes_HRV
            plot(app.UIAxes_HRV,0)
            hold(app.UIAxes_HRV,'on')
            s = stairs(app.UIAxes_HRV, hrv, 'linewidth', 1, 'color','r');
            legend(app.UIAxes_HRV, s,'Heart Rate Variability (HRV)','FontSize', 9, 'Location','northeast');
            
            app.UIAxes_HRV.XLabel.String = 'time (s)';
            app.UIAxes_HRV.YLabel.String = 'HRV (beats/min)';
            app.UIAxes_HRV.XLim = [0 120];
            app.UIAxes_HRV.YLim = [60 100];
            hold(app.UIAxes_HRV,'off')
            close(gcf);
            
            
            %% show mean heart rate value on MeanHeartRateEditField
            app.MeanHeartRateEditField.Value = hr;
            
            
            %% determine if the mean heart rate in normal range
            if app.MeanHeartRateEditField.Value < 60 || app.MeanHeartRateEditField.Value > 100
                app.Lamp_HR.Color = 'red';
            else
                app.Lamp_HR.Color = 'green';
            end
        end

        % Button pushed function: PlotPRV
        function PlotPRVButtonPushed(app, event)
            %% error detection
            if app.load_data == 0 
                errordlg('please load data first')
                return
            end           
            if app.load_raw_sig == 0
                errordlg('please load raw signal first')
                return  
            end
            if app.findpeak == 0
                errordlg('please findpeak first')
                return  
            end
            
            
            %% calculate Pulse Rate Variability (use app.ppg_pos property)
            j=1;
            n = length(app.ppg_pos);
            p = [];
            for i = 1:n-1
                p(j)= app.ppg_pos(i+1)-app.ppg_pos(i); 
                j=j+1;
            end 
            pr = 60./mean(p);   % 60/ mean of pulse rate PP interval (beats/min)
            prv = 60./p;        % 60/ each pulse rate PP interval    (beats/min)
            
            
            %% plot result on app.UIAxes_PRV
            plot(app.UIAxes_PRV,0)
            hold(app.UIAxes_PRV,'on')
            s = stairs(app.UIAxes_PRV, prv,'linewidth',1 ,'color', '#0072BD');
            legend(app.UIAxes_PRV, s,'Pulse Rate Variability (PRV)','FontSize', 9, 'Location','northeast');
            
            app.UIAxes_PRV.Title.String = 'PRV';
            app.UIAxes_PRV.XLabel.String = 'time (s)';
            app.UIAxes_PRV.YLabel.String = 'PRV (beats/min)';
            app.UIAxes_PRV.XLim = [0 120];
            app.UIAxes_PRV.YLim = [60 100];
            hold(app.UIAxes_PRV,'off');
            close(gcf);
            
            
            %% show mean pulse rate value on MeanPulseRateEditField
            app.MeanPulseRateEditField.Value = pr;
            
            
            %% determine if the mean pulse rate in normal range
            if app.MeanPulseRateEditField.Value < 60 || app.MeanPulseRateEditField.Value > 100
                app.Lamp_PR.Color = 'red';
            else
                app.Lamp_PR.Color = 'green';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [10 9 623 463];

            % Create LoaddataTab
            app.LoaddataTab = uitab(app.TabGroup);
            app.LoaddataTab.Title = 'Load data';

            % Create DataManagementPanel
            app.DataManagementPanel = uipanel(app.LoaddataTab);
            app.DataManagementPanel.Title = 'Data Management';
            app.DataManagementPanel.FontWeight = 'bold';
            app.DataManagementPanel.FontSize = 14;
            app.DataManagementPanel.Position = [1 1 150 437];

            % Create LoadButton
            app.LoadButton = uibutton(app.DataManagementPanel, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.FontSize = 14;
            app.LoadButton.Position = [31 317 88 24];
            app.LoadButton.Text = 'Load';

            % Create DataViewerPanel
            app.DataViewerPanel = uipanel(app.LoaddataTab);
            app.DataViewerPanel.Title = 'Data Viewer';
            app.DataViewerPanel.FontWeight = 'bold';
            app.DataViewerPanel.FontSize = 14;
            app.DataViewerPanel.Position = [150 1 472 437];

            % Create FilePathEditFieldLabel
            app.FilePathEditFieldLabel = uilabel(app.DataViewerPanel);
            app.FilePathEditFieldLabel.HorizontalAlignment = 'right';
            app.FilePathEditFieldLabel.FontSize = 14;
            app.FilePathEditFieldLabel.Position = [39 364 60 22];
            app.FilePathEditFieldLabel.Text = 'File Path';

            % Create FilePathEditField
            app.FilePathEditField = uieditfield(app.DataViewerPanel, 'text');
            app.FilePathEditField.FontSize = 14;
            app.FilePathEditField.Position = [114 364 310 24];

            % Create UITable
            app.UITable = uitable(app.DataViewerPanel);
            app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable.RowName = {};
            app.UITable.FontWeight = 'bold';
            app.UITable.Position = [39 20 399 321];

            % Create PlotECGPPGSignalTab
            app.PlotECGPPGSignalTab = uitab(app.TabGroup);
            app.PlotECGPPGSignalTab.Title = 'Plot ECG & PPG Signal';

            % Create Panel
            app.Panel = uipanel(app.PlotECGPPGSignalTab);
            app.Panel.FontWeight = 'bold';
            app.Panel.FontSize = 14;
            app.Panel.Position = [1 0 621 55];

            % Create LoadRawSignalButton
            app.LoadRawSignalButton = uibutton(app.Panel, 'push');
            app.LoadRawSignalButton.ButtonPushedFcn = createCallbackFcn(app, @LoadRawSignalButtonPushed, true);
            app.LoadRawSignalButton.FontSize = 14;
            app.LoadRawSignalButton.Position = [88.5 15 121 24];
            app.LoadRawSignalButton.Text = 'Load Raw Signal';

            % Create FindPeakButton
            app.FindPeakButton = uibutton(app.Panel, 'push');
            app.FindPeakButton.ButtonPushedFcn = createCallbackFcn(app, @FindPeakButtonPushed, true);
            app.FindPeakButton.FontSize = 14;
            app.FindPeakButton.Position = [272 15 100 24];
            app.FindPeakButton.Text = 'Find Peak';

            % Create ScaleButton
            app.ScaleButton = uibutton(app.Panel, 'push');
            app.ScaleButton.ButtonPushedFcn = createCallbackFcn(app, @ScaleButtonPushed, true);
            app.ScaleButton.FontSize = 14;
            app.ScaleButton.Position = [442 15 100 24];
            app.ScaleButton.Text = 'Scale';

            % Create Panel_2
            app.Panel_2 = uipanel(app.PlotECGPPGSignalTab);
            app.Panel_2.FontWeight = 'bold';
            app.Panel_2.FontSize = 14;
            app.Panel_2.Position = [1 54 621 384];

            % Create Panel_5
            app.Panel_5 = uipanel(app.PlotECGPPGSignalTab);
            app.Panel_5.FontWeight = 'bold';
            app.Panel_5.FontSize = 14;
            app.Panel_5.Position = [2 54 621 377];

            % Create UIAxes_raw_sig
            app.UIAxes_raw_sig = uiaxes(app.PlotECGPPGSignalTab);
            title(app.UIAxes_raw_sig, 'raw signal')
            xlabel(app.UIAxes_raw_sig, 'time(s)')
            ylabel(app.UIAxes_raw_sig, '')
            app.UIAxes_raw_sig.FontSize = 15;
            app.UIAxes_raw_sig.Position = [8 54 596 375];

            % Create PlotPTTTab
            app.PlotPTTTab = uitab(app.TabGroup);
            app.PlotPTTTab.Title = 'Plot PTT';

            % Create PTTPanel
            app.PTTPanel = uipanel(app.PlotPTTTab);
            app.PTTPanel.Title = 'PTT';
            app.PTTPanel.FontWeight = 'bold';
            app.PTTPanel.FontSize = 14;
            app.PTTPanel.Position = [1 1 150 437];

            % Create PlotPTT
            app.PlotPTT = uibutton(app.PTTPanel, 'push');
            app.PlotPTT.ButtonPushedFcn = createCallbackFcn(app, @PlotPTTPushed, true);
            app.PlotPTT.FontSize = 14;
            app.PlotPTT.Position = [33 281 83 24];
            app.PlotPTT.Text = 'Plot';

            % Create meanPTTEditFieldLabel
            app.meanPTTEditFieldLabel = uilabel(app.PTTPanel);
            app.meanPTTEditFieldLabel.HorizontalAlignment = 'center';
            app.meanPTTEditFieldLabel.FontSize = 14;
            app.meanPTTEditFieldLabel.FontWeight = 'bold';
            app.meanPTTEditFieldLabel.Position = [5 206 145 22];
            app.meanPTTEditFieldLabel.Text = 'mean PTT :';

            % Create meanPTTEditField
            app.meanPTTEditField = uieditfield(app.PTTPanel, 'numeric');
            app.meanPTTEditField.ValueDisplayFormat = '%.3f';
            app.meanPTTEditField.HorizontalAlignment = 'center';
            app.meanPTTEditField.FontSize = 14;
            app.meanPTTEditField.FontWeight = 'bold';
            app.meanPTTEditField.Position = [43 176 63 22];

            % Create sLabel
            app.sLabel = uilabel(app.PTTPanel);
            app.sLabel.FontSize = 15;
            app.sLabel.Position = [110 176 25 22];
            app.sLabel.Text = 's';

            % Create ResultViewerPanel_2
            app.ResultViewerPanel_2 = uipanel(app.PlotPTTTab);
            app.ResultViewerPanel_2.Title = 'Result Viewer';
            app.ResultViewerPanel_2.FontWeight = 'bold';
            app.ResultViewerPanel_2.FontSize = 14;
            app.ResultViewerPanel_2.Position = [150 1 472 437];

            % Create UIAxes_PTT
            app.UIAxes_PTT = uiaxes(app.ResultViewerPanel_2);
            title(app.UIAxes_PTT, 'Pulse Transit Time (PTT)')
            xlabel(app.UIAxes_PTT, 'time(s)')
            ylabel(app.UIAxes_PTT, 'time(s)')
            app.UIAxes_PTT.FontSize = 14;
            app.UIAxes_PTT.Position = [1 1 471 411];

            % Create PlotBPTab
            app.PlotBPTab = uitab(app.TabGroup);
            app.PlotBPTab.Title = 'Plot BP';

            % Create BPPanel
            app.BPPanel = uipanel(app.PlotBPTab);
            app.BPPanel.Title = 'BP';
            app.BPPanel.FontWeight = 'bold';
            app.BPPanel.FontSize = 14;
            app.BPPanel.Position = [1 1 186 437];

            % Create HeightEditFieldLabel
            app.HeightEditFieldLabel = uilabel(app.BPPanel);
            app.HeightEditFieldLabel.HorizontalAlignment = 'right';
            app.HeightEditFieldLabel.FontSize = 14;
            app.HeightEditFieldLabel.FontWeight = 'bold';
            app.HeightEditFieldLabel.Position = [31 336 49 22];
            app.HeightEditFieldLabel.Text = 'Height';

            % Create HeightEditField
            app.HeightEditField = uieditfield(app.BPPanel, 'numeric');
            app.HeightEditField.ValueDisplayFormat = '%.3f';
            app.HeightEditField.ValueChangedFcn = createCallbackFcn(app, @HeightEditFieldValueChanged, true);
            app.HeightEditField.HorizontalAlignment = 'center';
            app.HeightEditField.FontSize = 14;
            app.HeightEditField.Position = [85 336 50 22];

            % Create PlotBP
            app.PlotBP = uibutton(app.BPPanel, 'push');
            app.PlotBP.ButtonPushedFcn = createCallbackFcn(app, @PlotBPPushed, true);
            app.PlotBP.FontSize = 14;
            app.PlotBP.Position = [54 303 83 24];
            app.PlotBP.Text = 'Plot';

            % Create SystolicBloodPressureLabel
            app.SystolicBloodPressureLabel = uilabel(app.BPPanel);
            app.SystolicBloodPressureLabel.HorizontalAlignment = 'center';
            app.SystolicBloodPressureLabel.FontSize = 13;
            app.SystolicBloodPressureLabel.FontWeight = 'bold';
            app.SystolicBloodPressureLabel.Position = [11 162 163 22];
            app.SystolicBloodPressureLabel.Text = {'Systolic Blood Pressure :'; ''};

            % Create SystolicBloodPressureEditField
            app.SystolicBloodPressureEditField = uieditfield(app.BPPanel, 'numeric');
            app.SystolicBloodPressureEditField.ValueDisplayFormat = '%.2f';
            app.SystolicBloodPressureEditField.HorizontalAlignment = 'center';
            app.SystolicBloodPressureEditField.FontSize = 13;
            app.SystolicBloodPressureEditField.FontWeight = 'bold';
            app.SystolicBloodPressureEditField.Position = [56 137 65 22];

            % Create MeanBloodPressureLabel
            app.MeanBloodPressureLabel = uilabel(app.BPPanel);
            app.MeanBloodPressureLabel.HorizontalAlignment = 'center';
            app.MeanBloodPressureLabel.FontSize = 13;
            app.MeanBloodPressureLabel.FontWeight = 'bold';
            app.MeanBloodPressureLabel.Position = [18 93 149 31];
            app.MeanBloodPressureLabel.Text = {'Mean Blood Pressure :'; ''; ''};

            % Create MeanBloodPressureEditField
            app.MeanBloodPressureEditField = uieditfield(app.BPPanel, 'numeric');
            app.MeanBloodPressureEditField.ValueDisplayFormat = '%.2f';
            app.MeanBloodPressureEditField.HorizontalAlignment = 'center';
            app.MeanBloodPressureEditField.FontSize = 13;
            app.MeanBloodPressureEditField.FontWeight = 'bold';
            app.MeanBloodPressureEditField.Position = [56 80 63 22];

            % Create DiastolicBloodPressureLabel
            app.DiastolicBloodPressureLabel = uilabel(app.BPPanel);
            app.DiastolicBloodPressureLabel.HorizontalAlignment = 'center';
            app.DiastolicBloodPressureLabel.FontSize = 13;
            app.DiastolicBloodPressureLabel.FontWeight = 'bold';
            app.DiastolicBloodPressureLabel.Position = [7 46 171 22];
            app.DiastolicBloodPressureLabel.Text = {'Diastolic Blood Pressure : '; ''};

            % Create DiastolicBloodPressureEditField
            app.DiastolicBloodPressureEditField = uieditfield(app.BPPanel, 'numeric');
            app.DiastolicBloodPressureEditField.ValueDisplayFormat = '%.2f';
            app.DiastolicBloodPressureEditField.HorizontalAlignment = 'center';
            app.DiastolicBloodPressureEditField.FontSize = 13;
            app.DiastolicBloodPressureEditField.FontWeight = 'bold';
            app.DiastolicBloodPressureEditField.Position = [57 23 63 22];

            % Create pleaseenterheightbelowLabel
            app.pleaseenterheightbelowLabel = uilabel(app.BPPanel);
            app.pleaseenterheightbelowLabel.HorizontalAlignment = 'center';
            app.pleaseenterheightbelowLabel.FontSize = 14;
            app.pleaseenterheightbelowLabel.FontWeight = 'bold';
            app.pleaseenterheightbelowLabel.Position = [8 363 176 22];
            app.pleaseenterheightbelowLabel.Text = 'please enter height below';

            % Create mLabel
            app.mLabel = uilabel(app.BPPanel);
            app.mLabel.FontSize = 14;
            app.mLabel.Position = [138 334 25 22];
            app.mLabel.Text = 'm';

            % Create mmHgLabel
            app.mmHgLabel = uilabel(app.BPPanel);
            app.mmHgLabel.Position = [124 136 40 22];
            app.mmHgLabel.Text = 'mmHg';

            % Create mmHgLabel_4
            app.mmHgLabel_4 = uilabel(app.BPPanel);
            app.mmHgLabel_4.Position = [122 79 40 22];
            app.mmHgLabel_4.Text = 'mmHg';

            % Create mmHgLabel_5
            app.mmHgLabel_5 = uilabel(app.BPPanel);
            app.mmHgLabel_5.Position = [123 23 40 22];
            app.mmHgLabel_5.Text = 'mmHg';

            % Create Lamp_SBP
            app.Lamp_SBP = uilamp(app.BPPanel);
            app.Lamp_SBP.Position = [23 138 20 20];
            app.Lamp_SBP.Color = [0.902 0.902 0.902];

            % Create Lamp_DBP
            app.Lamp_DBP = uilamp(app.BPPanel);
            app.Lamp_DBP.Position = [23 24 20 20];
            app.Lamp_DBP.Color = [0.902 0.902 0.902];

            % Create ResultViewerPanel
            app.ResultViewerPanel = uipanel(app.PlotBPTab);
            app.ResultViewerPanel.Title = 'Result Viewer';
            app.ResultViewerPanel.FontWeight = 'bold';
            app.ResultViewerPanel.FontSize = 14;
            app.ResultViewerPanel.Position = [186 1 436 437];

            % Create UIAxes_BP
            app.UIAxes_BP = uiaxes(app.ResultViewerPanel);
            title(app.UIAxes_BP, 'Blood Pressure (BP)')
            xlabel(app.UIAxes_BP, 'time(s)')
            ylabel(app.UIAxes_BP, 'mmHg')
            app.UIAxes_BP.FontSize = 14;
            app.UIAxes_BP.Position = [0 1 435 411];

            % Create PlotHRVTab
            app.PlotHRVTab = uitab(app.TabGroup);
            app.PlotHRVTab.Title = 'Plot HRV';

            % Create HRVPanel
            app.HRVPanel = uipanel(app.PlotHRVTab);
            app.HRVPanel.Title = 'HRV';
            app.HRVPanel.FontWeight = 'bold';
            app.HRVPanel.FontSize = 14;
            app.HRVPanel.Position = [1 1 150 437];

            % Create PlotHRV
            app.PlotHRV = uibutton(app.HRVPanel, 'push');
            app.PlotHRV.ButtonPushedFcn = createCallbackFcn(app, @PlotHRVPushed, true);
            app.PlotHRV.FontSize = 14;
            app.PlotHRV.Position = [33 281 83 24];
            app.PlotHRV.Text = 'Plot';

            % Create MeanHeartRateEditFieldLabel
            app.MeanHeartRateEditFieldLabel = uilabel(app.HRVPanel);
            app.MeanHeartRateEditFieldLabel.HorizontalAlignment = 'center';
            app.MeanHeartRateEditFieldLabel.FontSize = 14;
            app.MeanHeartRateEditFieldLabel.FontWeight = 'bold';
            app.MeanHeartRateEditFieldLabel.Position = [5 206 145 22];
            app.MeanHeartRateEditFieldLabel.Text = {'Mean Heart Rate :'; ''};

            % Create MeanHeartRateEditField
            app.MeanHeartRateEditField = uieditfield(app.HRVPanel, 'numeric');
            app.MeanHeartRateEditField.ValueDisplayFormat = '%.2f';
            app.MeanHeartRateEditField.HorizontalAlignment = 'center';
            app.MeanHeartRateEditField.FontSize = 13;
            app.MeanHeartRateEditField.FontWeight = 'bold';
            app.MeanHeartRateEditField.Position = [43 175 63 22];

            % Create beatsminLabel
            app.beatsminLabel = uilabel(app.HRVPanel);
            app.beatsminLabel.FontSize = 11;
            app.beatsminLabel.Position = [112 174 34 25];
            app.beatsminLabel.Text = {'beats/'; 'min'};

            % Create Lamp_HR
            app.Lamp_HR = uilamp(app.HRVPanel);
            app.Lamp_HR.Position = [14 176 20 20];
            app.Lamp_HR.Color = [0.902 0.902 0.902];

            % Create ResultViewerPanel_4
            app.ResultViewerPanel_4 = uipanel(app.PlotHRVTab);
            app.ResultViewerPanel_4.Title = 'Result Viewer';
            app.ResultViewerPanel_4.FontWeight = 'bold';
            app.ResultViewerPanel_4.FontSize = 14;
            app.ResultViewerPanel_4.Position = [150 1 472 437];

            % Create UIAxes_HRV
            app.UIAxes_HRV = uiaxes(app.ResultViewerPanel_4);
            title(app.UIAxes_HRV, 'Heart Rate Variability (HRV)')
            xlabel(app.UIAxes_HRV, 'time(s)')
            ylabel(app.UIAxes_HRV, 'beats / min')
            app.UIAxes_HRV.FontSize = 14;
            app.UIAxes_HRV.Position = [1 -2 462 415];

            % Create PlotPRVTab
            app.PlotPRVTab = uitab(app.TabGroup);
            app.PlotPRVTab.Title = 'Plot PRV';

            % Create PRVPanel
            app.PRVPanel = uipanel(app.PlotPRVTab);
            app.PRVPanel.Title = 'PRV';
            app.PRVPanel.FontWeight = 'bold';
            app.PRVPanel.FontSize = 14;
            app.PRVPanel.Position = [1 1 150 437];

            % Create PlotPRV
            app.PlotPRV = uibutton(app.PRVPanel, 'push');
            app.PlotPRV.ButtonPushedFcn = createCallbackFcn(app, @PlotPRVButtonPushed, true);
            app.PlotPRV.FontSize = 14;
            app.PlotPRV.Position = [33 281 83 24];
            app.PlotPRV.Text = 'Plot';

            % Create MeanPulseRateEditFieldLabel
            app.MeanPulseRateEditFieldLabel = uilabel(app.PRVPanel);
            app.MeanPulseRateEditFieldLabel.HorizontalAlignment = 'center';
            app.MeanPulseRateEditFieldLabel.FontSize = 14;
            app.MeanPulseRateEditFieldLabel.FontWeight = 'bold';
            app.MeanPulseRateEditFieldLabel.Position = [5 206 145 22];
            app.MeanPulseRateEditFieldLabel.Text = {'Mean Pulse Rate :'; ''};

            % Create MeanPulseRateEditField
            app.MeanPulseRateEditField = uieditfield(app.PRVPanel, 'numeric');
            app.MeanPulseRateEditField.ValueDisplayFormat = '%.2f';
            app.MeanPulseRateEditField.HorizontalAlignment = 'center';
            app.MeanPulseRateEditField.FontSize = 13;
            app.MeanPulseRateEditField.FontWeight = 'bold';
            app.MeanPulseRateEditField.Position = [43 175 63 22];

            % Create beatsminLabel_2
            app.beatsminLabel_2 = uilabel(app.PRVPanel);
            app.beatsminLabel_2.FontSize = 11;
            app.beatsminLabel_2.Position = [112 174 34 25];
            app.beatsminLabel_2.Text = {'beats/'; 'min'};

            % Create Lamp_PR
            app.Lamp_PR = uilamp(app.PRVPanel);
            app.Lamp_PR.Position = [14 176 20 20];
            app.Lamp_PR.Color = [0.902 0.902 0.902];

            % Create ResultViewerPanel_3
            app.ResultViewerPanel_3 = uipanel(app.PlotPRVTab);
            app.ResultViewerPanel_3.Title = 'Result Viewer';
            app.ResultViewerPanel_3.FontWeight = 'bold';
            app.ResultViewerPanel_3.FontSize = 14;
            app.ResultViewerPanel_3.Position = [150 1 472 437];

            % Create UIAxes_PRV
            app.UIAxes_PRV = uiaxes(app.ResultViewerPanel_3);
            title(app.UIAxes_PRV, 'Pulse Rate Variability (PRV)')
            xlabel(app.UIAxes_PRV, 'time(s)')
            ylabel(app.UIAxes_PRV, 'beats / min')
            app.UIAxes_PRV.FontSize = 14;
            app.UIAxes_PRV.Position = [0 1 462 413];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end