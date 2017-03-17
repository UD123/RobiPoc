function SC_MainGUI
% SC_MainGUI - Creates a startup gui to run different tests and algorithms

%-----------------------------
% Ver	Date	 Who	Descr
%-----------------------------
% See README.txt
%-----------------------------

% version
currVers    = '03.04'; 

% deal with path
p = path;
si = regexp(p,'C:\\Projects\\Tyto\.*','start');
se = regexp(p,';','end');
for m = 1:length(si),
    rp = p(si(m):se(m));
    rmpath(rp);
end

% connect
if ~isdeployed
addpath(genpath('Test'));
addpath(genpath('Src'));
addpath(genpath('Build'));
addpath(genpath('Tools'));
end
tic; % ShowText requires it one time

clear global;
clear class;

% global data
global Par 


% Control params
Par                 = SC_ManageParam(currVers);
hm                  = SC_HistROI(); % small patch


%btnStartStop        = SC_ToggleButton();

% manage default user settings
mngSession          = SC_ManageSession();  % can not load without init definition
dirName             = '';

% build all the buttons
fSetupGUI();

% Update figure components
%fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fManageSession (nested in main)
% * *
% * * save,load and clear current session data
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fManageSession(hObject, eventdata, selType)
        
        %warndlg('Is Yet to Come')
        %return
        
        %userSessionFileName    = fullfile(Par.Setup.Dir,Par.Setup.FileName);
        
        switch selType,
            
            case 1, % load last session
                
                mngSession = LoadLastSession(mngSession);                
                
            case 11, % load session user mode
                
                [csFilenames, sPath] = uigetfile(...
                    {   '*.mat', 'mat Files'; '*.*', 'All Files'}, ...
                    'OpenLocation'  , Par.Setup.Dir, ...
                    'Multiselect'   , 'off');
                
                if isnumeric(sPath), return, end;   % Dialog aborted
                
                % if single file selected
                if iscell(csFilenames), csFilenames = csFilenames{1}; end;
                userSessionFileName    = fullfile(sPath,csFilenames);
                
                mngSession = LoadLastSession(mngSession, userSessionFileName);                
                
                % remember the name of the session
                Par.Setup.FileName      = csFilenames;
                Par.Setup.Dir           = sPath;
                SC_ManageText([], sprintf('Session : loaded from file %s. ',userSessionFileName), 'I' ,0)   ;
                
            case 2, % save the session
                
                mngSession = SaveLastSession(mngSession);                
               
            case 12, % save session as...
                
                [filename, pathname] = uiputfile('*.mat', 'Save Session file',Par.Setup.FileName);
                if isequal(filename,0) || isequal(pathname,0),  return;    end
                
                if iscell(filename), filename = filename{1}; end;
                userSessionFileName = fullfile(pathname, filename);
                
                mngSession = SaveLastSession(mngSession,userSessionFileName);            
                
                % remember the name of the session
                Par.Setup.FileName      = filename;
                Par.Setup.Dir           = pathname;
                SC_ManageText([], sprintf('Session : saved to file %s. ',userSessionFileName), 'I' ,0)   ;
                
            case 3, % clear/new session
                
                %                 buttonName = questdlg('All the numbering of ROis and Events will be lost', 'Warning');
                %                 if ~strcmp(buttonName,'Yes'), return; end;
                %
                %                 SSave.ExpDir        = Par.DMT.VideoDir;
                %
                %                 SC_ManageText([], sprintf('Session : Clearing all the video and analysis data.'), 'W' ,0)   ;
                %                % Clear all the previous data
                %                 SData           = struct('imBehaive',[],'imTwoPhoton',[],'strROI',[],'strEvent',[]);
                %                 Par             = TPA_ParInit;
                %
                %                 try %#ok<TRYNC>
                %                     save(userSessionFileName,'-struct', 'SSave');
                %                 end
                
                % close figures
                fCloseFigures(0,0)    ;
                
            otherwise
                error('Bad session selection %d',selType)
        end
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
        
    end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fManageImage (nested in main)
% * *
% * * Define system params
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fManageImage(hObject, eventdata, selType)
        
        % enable image path
        Par.Config.ImageTestEnb         = true;
        
        
        switch selType,
            
            case 1, % Select Target Type
                
                Par.Image           = SetTargetType(Par.Image);
            
            case 2, % Select Test Type
                
                Par.Image           = SetTestType(Par.Image);                
                
            case 3, % Select Source
                
                % Configuration also does connect
                Par.Image           = SelectDataSource(Par.Image);
               
                
            case 4, % Test Connect
                
                % Configuration also does connect
                try
                    [Par.Image,videoFrame]  = GetData(Par.Image);
                catch
                    Par.Image               = Finish(Par.Image);
                    videoFrame              = [];
                    warndlg('Try the connection again');
                end
                if ~isempty(videoFrame),
                    warndlg('Connection is OK');
                else
                    errordlg('Can not connect or find the data source')
                end
  
                
            case 11, % Source params
                
                % select params
                Par.Image.Data                  = SetParameters(Par.Image.Data);
                
            case 12, % Select Registration and Tracking method params
                
                % select params
                Par.Image.Track                 = SetParameters(Par.Image.Track);
                
            case 13, % Set Quality Method for test
                
                % select params
                Par.Image.Quality               = SetParameters(Par.Image.Quality);
               
            case 14, % Configure Lens Distortion
                
                % select params
                Par.Image.Distort               = SetParameters(Par.Image.Distort);
                %Par.Image.Distort               = SetParameters(Par.Image.Distort);
                
            case 15, % Configure Dirt Detection
                
                % select params
                Par.Image.Distort               = SetParameters(Par.Image.Distort);
                
              
           case 21, % Single Image ROI
                
                % select single image
                 hm = Process(hm,[],61);
                
%                AvgColor();
                 
            case 22, % Registration
                
                % select which algo to use
                algoList    = num2str((1:5)');               
                [s,ok]      = listdlg('PromptString','Select Fiducial Algo for Registration :','ListString',algoList,'SelectionMode','multi','ListSize',[160 200]);
                if ~ok, return; end;
                algType     = s;
%                Par.Image.Reg  = TestAllAlg(Par.Image.Reg,1,algType,121);

                Par.Image.Track  = TestFiducialDetect(Par.Image.Track,99,algType,101 + algType*10);
                

            case 23, % Quality
                
                SC_ManageText([],'Not supported Yet','W');
                
           case 24, % Lens Distortion Run
                                
                Par.Image.Distort               = ComputeDistortion(Par.Image.Distort);
                %cameraCalibrator();
                
           case 25, % Run Dirt detect
                                
                Par.Image.Dirt                  = TestMultipleImages(Par.Image.Dirt);
                
              
            case 33, % Load Params from XML : NA
                % Read
                Par                             = ReadXML(Par);
                
            case 51, % Run the test
                
                 %Par.Image                      = TestRun(Par.Image);
                 Par.Image                      = SystemRun(Par.Image);
                 
            otherwise
                error('Bad system selection %d',selType)
        end
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
        
    end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fManageSound (nested in main)
% * *
% * * Define Algo params
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fManageSound(hObject, eventdata, selType)
        
        % disable image path
        Par.Config.ImageTestEnb         = false;
        
        switch selType,
            
            case 1, % Sound Input Type
                 % Input
                Par.Sound = SelectAudioInput(Par.Sound,0,0);
                 % output
                Par.Sound = SelectAudioOutput(Par.Sound,0,0);
%                 SC_ManageText([], sprintf('Algo : Using algorithm %s.',Par.Config.InUse(m).AlgName), 'I' ,0)   ;
%                 
%                 % init the appropriate class
%                 Par         = AlgorithmInit(Par);
                
                
            case 2, % Config Params
                                
                %warndlg('Is Yet to Come')
                %return
                Par.Sound = ConfigParams(Par.Sound,0,0);
%                 if ~isOK,
%                     SC_ManageText([], 'Algo : No parameter is changed', 'W' ,0)   ;
%                 end
                
                
             case 3, % Connect
                %warndlg('Is yet to come')
              
               Par.Sound = TestRealTime(Par.Sound,0,0);

                
            case 4, % Sound Tool
                %Par.Stat              = Init(Par.Stat,Par);
                %addpath('C:\Projects\Tyto\Algo\Device\AlgSteth\Test\Performance');
                sm  = AUDIO_LoopbackTest(true);
                
            case 5, % File Compare Tool
                %Par.Stat              = Init(Par.Stat,Par);
                %addpath('C:\Projects\Tyto\Algo\Device\AlgSteth\Test\Performance');
                sc  = TEST_CompareFiles();
 
                
            case 11, % calib
                %warndlg('Is yet to come')
                dirName = SC_ShowSoundXmlFiles(dirName);
                
            otherwise
                error('Bad sound selection %d',selType)
        end
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
    end


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fManageProcess (nested in main)
% * *
% * * Start/Stop data processing
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fManageProcess(hObject, eventdata, selType)
        
%         if isempty(Par.System.BoardSetup),
%             warndlg('System Selection is required first.')
%             return;
%         end
        
        switch selType,
            case 1, % Scope
                
                % check double click
                if Par.Config.State  == Par.STATES.START,
                    warndlg('System is running. Press Stop Acquisition first','','modal')
                    return
                end
                
                set(Par.Handles.hStartStop,'string','Stop','BackgroundColor',[0.9 0 0]);
                
                Par.Config.State   = Par.STATES.START; % default
                % single iteration
                %Par.Algo.MaxIterNum = 1e8;  % many iterations
                % Run
                SC_SystemRun(0,0);
                %Par                 = SystemRun(Par);                
                % parameters are going by global
                % return back colors
                fManageProcess(0, 0, 3);                

                     
%                 acquireTime             = Par.System.AcquisitionTime;
%                 Par.System.BoardSetup   = Par.System.BoardSetup.GetData(acquireTime);
                
            case 2, % Single
%                 if Par.Config.State  == Par.Config.STATES.START,
%                     warndlg('System is running. Press Stop Acquisition first','','modal')
%                     return
%                 end
%                 
%                 set(S.hSingle,'string','Stop','BackgroundColor',[0.9 0 0]);
%                 
%                 Par.Config.State   = Par.Config.STATES.START; % default
%                 Par.System.Mode    = Par.System.MODETYPES.OFFLINE;
%                 % time is splitted on iterations - 1 sec at most
%                 %requestedTime      = Par.System.AcquisitionTime;
%                 Par.Algo.MaxIterNum = 1; %ceil(requestedTime);  % one iteration
%                 %Par.System.AcquisitionTime = 1; % max 1 sec
%                 % run
%                 ALB_SystemRun(0,0);
%                 % return back the time
%                 %Par.System.AcquisitionTime = requestedTime;
%                 % return back colors
%                 fManageProcess(0, 0, 3);                
                
            case 3, % Stop
                
                Par.Config.State    = Par.STATES.STOP; % default
                set(Par.Handles.hStartStop,'string','Start','value',0,'BackgroundColor',[0 0.8 0]);
                set(Par.Handles.hSingle,'string','Single','value',0,'BackgroundColor',[0 0.8 0]);
                
                
%                 maxNumPulses            = Par.System.AcquisitionNum;
%                 acqNum                  = sum(Par.System.BoardSetup.BoardLastPacket - Par.System.BoardSetup.BoardFirstPacket);
%                 % for the start
%                 acqNum                  = min(maxNumPulses,acqNum);
                %fprintf('I : GUI getting %d packets from the DAQ\n',acqNum);
                
%                 [Par.System.BoardSetup,isOK] = GetDataOffline(Par.System.BoardSetup,acqNum);
%                 
%                 if isOK,
%                     warndlg('Data is transfered from DAQ to PC','Data Info','modal')   ;
%                 else
%                     errordlg('Can not connect or read data from the DAQ','Data Info','modal')   ;
%                 end
                
             case 4, % Release
                 
                
             case 5, % Stop
                
                %Par.Config.State    = Par.Config.STATES.STOP; % default
                
            case 11, % Strt/Stop button
                
%                btnStartStop.OnStateChange();
                
                if get(Par.Handles.hStartStop,'value') > 0,
                    fManageProcess(0, 0, 1);
                else
                    %Par.Config.State    = Par.Config.STATES.STOP; % default
                    fManageProcess(0, 0, 3);
                end
                
            case 12, % Single button
                
                if get(Par.Handles.hSingle,'value') > 0,
                    fManageProcess(0, 0, 2);
                    
                else
                    %Par.Config.State    = Par.Config.STATES.STOP; % default
                    fManageProcess(0, 0, 3);                    
                end
                
            otherwise
                error('Bad process selection %d',selType)
        end
        
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
        
    end


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fViewResults (nested in main)
% * *
% * * View final and intermediate data processing results
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fManageResults(hObject, eventdata, selType)
        % toggle views
        
        switch selType,
            
            case 1, % Select
                
                %Par.Config          = SelectViewType(Par.Config);  
                dirName = ReadBigServerLog(dirName);
                
                % check if required here
                %SC_ManageText([], sprintf('View : New views are selected.'), 'I' ,0)   ;

            case 2, % Configure
                
               
               
            case 4, % init statistics
                
                
%             case 3, % Error
%                 %S.View.ERROR            = 1 - S.View.ERROR; % default
%                 Par.Config.View.ERROR   = 1 - Par.Config.View.ERROR; % default
%                 
%             case 4, % Scatter
%                 Par.Config.View.SCATTER  = 1 - Par.Config.View.SCATTER; % default
            
            
            case 11, % Sound Manager from Device
               
%                 addpath('C:\Projects\Tyto\Algo\Device\AlgSteth\Test\Performance');
                 %sm  = AUDIO_LoopbackTest();
                
            case 12, % Define Filter s and else
                
                
            case 13, % Pause
                warndlg('Is yet to come')
                
               
                
            otherwise
                error('Bad selection %d',selType)
        end
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
        
    end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * *
% * * NESTED FUNCTION fExportResults (nested in main)
% * *
% * * Export final and intermediate data processing results
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fExportResults(hObject, eventdata, selType)
        
        switch selType,
   
            case 2,
            
            case 3,
            
            case 4,
                [sFilenames, sPath] = uigetfile(...
                {   '*.mat', 'mat Files'; '*.*', 'All Files'}, ...
                'OpenLocation'  , Par.Setup.Dir, ...
                'Multiselect'   , 'off');
                if isnumeric(sPath), return, end;   % Dialog aborted
                loadFileName  = fullfile(sPath,sFilenames);
                
               try
                    load(loadFileName,'dataNI');
                catch errMsg
                    % Give more information for mismatch.
                    errordlg(errMsg.message)
               end
               if isstruct(dataNI),
                   warndlg('Right now conversion is supported only for 4 chanel system')
                   return
               end
                
               % save
               saveFileName = [loadFileName,'.xslx'];
               stat    = xlswrite(saveFileName,mat2cell(1:size(dataNI,2)),    'dataNI','A1');
               stat    = xlswrite(saveFileName,dataNI,         'dataNI','A2');
               
            case 11,
                % Technician mode
                Par.Config.TechMode = gui_passw('tytocare2015');
                SC_ManageText([],  sprintf('Technician mode : %d',Par.Config.TechMode), 'W' ,0);
            otherwise
                error('Bad selType')
        end
        
        % Update figure components
        fUpdateGUI(); % Acitvate/deactivate some buttons according to the gui state
        
    end


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * NESTED FUNCTION fSetupGUI (nested in Main)
% * *
% * * Init all the buttons
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fSetupGUI() %#ok<*INUSD> eventdata is repeatedly unused
        
        
        S.hFig = figure('units','pixels',...
            'position',[200 250 450 30],...
            'menubar','none',...
            'name', ['TYTO Calibration Tool : ',currVers],...
            'numbertitle','off',...
            'toolbar','none',...
            'resize','off',...
            'tag','main',...
            'closerequestfcn',@fCloseGUI); %{@fh_crfcn});
        
        
        
        % session
        t = 1;
        S.hMenuFile(t)      = uimenu(S.hFig,'Label','Session...'); t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Load Latest ...',          'Callback',{@fManageSession,1});    t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Load From File ...',       'Callback',{@fManageSession,11});    t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Save Current ...',         'Callback',{@fManageSession,2});    t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Save To File ...',         'Callback',{@fManageSession,12});    t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Clear Session',            'Callback',{@fManageSession,3});    t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Arrange Figures',          'Callback',@fArrangeFigures ,   'separator','on');  t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Close Figures',            'Callback',@fCloseFigures ,     'separator','off');  t = t + 1;
        S.hMenuFile(t)      = uimenu(S.hMenuFile(1),'Label','Exit',                     'Callback',@fCloseGUI,          'separator','on');  t = t + 1;
        
        % image processing systems
        t = 1;
        S.hMenuImage(t)    = uimenu(S.hFig,           'Label','Image...'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Select Target Type ...',       'Callback',{@fManageImage,1}); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Select Test Type ...',         'Callback',{@fManageImage,2}); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Select Source ...',            'Callback',{@fManageImage,3}); t = t + 1;
        %S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test Connection...',           'Callback',{@fManageImage,4}); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Set Source Params...',         'Callback',{@fManageImage,11},'separator','on','Enable','on'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Set Tracking Params... ',      'Callback',{@fManageImage,12},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Set Quality Params... ',       'Callback',{@fManageImage,13},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Set Lens Distort. Params... ', 'Callback',{@fManageImage,14},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Set Dirt Detect Params... ',   'Callback',{@fManageImage,15},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test ROI Color ',              'Callback',{@fManageImage,21},'separator','on'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test Tracking ',               'Callback',{@fManageImage,22},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test Quality ',                'Callback',{@fManageImage,23},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test Lens Distortion ',        'Callback',{@fManageImage,24},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Test Dirt Detect ',            'Callback',{@fManageImage,25},'separator','off'); t = t + 1;
        S.hMenuImage(t)    = uimenu(S.hMenuImage(1),  'Label','Run Test.. ',                  'Callback',{@fManageImage,51},'separator','on'); t = t + 1;
        
        % Sound processing
        t = 1;
        S.hMenuSound(t)      = uimenu(S.hFig,            'Label','Sound...'); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','Select Input/Output...',         'Callback',{@fManageSound,1}); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','Config Params...',               'Callback',{@fManageSound,2}); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','Connect...',                     'Callback',{@fManageSound,3}, 'enable','on'); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','Sound Test Tool...',             'Callback',{@fManageSound,4}, 'enable','on','separator','on'); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','File Compare Tool...',           'Callback',{@fManageSound,5}, 'enable','on','separator','off'); t = t + 1;
        S.hMenuSound(t)      = uimenu(S.hMenuSound(1),    'Label','Show Xml Files...',              'Callback',{@fManageSound,11}, 'enable','on','separator','off'); t = t + 1;
        
%         % Processing
%         S.hMenuProcess(1)   = uimenu(S.hFig,'Label','Process...');
%         S.hMenuProcess(2)   = uimenu(S.hMenuProcess(1),'Label','Acquire Continuous  ...',         'Callback',{@fManageProcess,1});
%         S.hMenuProcess(3)   = uimenu(S.hMenuProcess(1),'Label','Acquire Single  ...',             'Callback',{@fManageProcess,2});
%         S.hMenuProcess(4)   = uimenu(S.hMenuProcess(1),'Label','Stop Acquisition ...',            'Callback',{@fManageProcess,3});
%         S.hMenuProcess(5)   = uimenu(S.hMenuProcess(1),'Label','Release Data...',                 'Callback',{@fManageProcess,4});
        
        % View results
        t = 1;
        S.hMenuView(t)      = uimenu(S.hFig,'Label','Results ...'); t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Temperature Log File to xls...',   'Callback',{@fManageResults,1}); t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Config Params...',                 'Callback',{@fManageResults,2}); t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Clear Statistics...',              'Callback',{@fManageResults,4}, 'separator','off'); t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Offline Analysis... ',             'Callback',{@fManageResults,12},'enable','off');    t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Pattern Analysis...',              'Callback',{@fManageResults,13},'enable','off','separator','on');    t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Results to CSV ...',               'Callback',{@fExportResults,2},'separator','on');   t = t + 1;
        S.hMenuView(t)      = uimenu(S.hMenuView(1),    'Label','Results to Excel ...',             'Callback',{@fExportResults,3},'separator','off');  t = t + 1;
        
        % Help
        t = 1;
        S.hMenuExport(1)    = uimenu(S.hFig,'Label','Help...'); t = t + 1;
        S.hMenuExport(2)    = uimenu(S.hMenuExport(1),      'Label','Manual ...',                  'Callback','open(''SC_UserManual.docx'')');
        S.hMenuExport(3)    = uimenu(S.hMenuExport(1),      'Label','How To ...',                  'Callback','open(''SC_UserManual.docx'')');
        S.hMenuExport(4)    = uimenu(S.hMenuExport(1),      'Label','About ...',                   'Callback','warndlg(''Created by : TytoCare'')');
        S.hMenuExport(5)    = uimenu(S.hMenuExport(1),      'Label','Technician Mode ...',         'Callback',{@fExportResults,11});
                
        
        % Start/Stop
        S.hStartStop = uicontrol('Style', 'togglebutton', 'String', 'Start',...
        'Position', [5 5 70 20],'BackgroundColor',[0 0.8 0],'Visible','off',...
        'Callback', {@fManageProcess,11});
 
        % Start/Stop
        S.hSingle = uicontrol('Style', 'togglebutton', 'String', 'Single',...
        'Position', [80+250 5 70 20],'BackgroundColor',[0 0.8 0],'Visible','off',...
        'Callback', {@fManageProcess,12});
 
        % save handles
        Par.Handles = S;
    
        
        fUpdateGUI() ;
        
        
    end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * NESTED FUNCTION fUpdateGUI (nested in Main)
% * *
% * * Defines state of all buttons
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fUpdateGUI() %#ok<*INUSD> eventdata is repeatedly unused
        
        
%         % support data source/save selection
%         checkOnOff = 'Off';
%         if Par.Data.LoadOn > 0 , checkOnOff = 'On'; end
%         set(Par.Handles.hMenuImage(6),'Checked',checkOnOff);
%         checkOnOff = 'Off';
%         if Par.Data.SaveOn > 0 , checkOnOff = 'On'; end
%         set(Par.Handles.hMenuImage(8),'Checked',checkOnOff);
%         checkOnOff = 'Off';
%         if Par.Debug.SynPulseOn  > 0 , checkOnOff = 'On'; end
%         set(Par.Handles.hMenuImage(11),'Checked',checkOnOff);
        
%         % technician
%         enb = 'off';
%         if Par.Config.TechMode, enb = 'on'; end;
%         
%         % show selected tool
%         set(Par.Handles.hMenuFile,'Enable',enb);  % always can select an image
%         set(Par.Handles.hMenuImage,'Enable',enb);  % always can select an image
%         set(Par.Handles.hMenuSound,'Enable',enb);
%         set(Par.Handles.hMenuView,'Enable',enb);
%         %set(Par.Handles.hMenuExport,'Enable',enb);
%         set(Par.Handles.hMenuImage([1 10]),'Enable','on');  % always can select an image
        
        
    end


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * NESTED FUNCTION fArrangeFigures (nested in Main)
% * *
% * * Arranges figures on the screen
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fArrangeFigures(o,e) %#ok<*INUSD> eventdata is repeatedly unused
        
        %
        try %#ok<TRYNC>
        end
    end
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * END NESTED FUNCTION fArrangeFigures
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =



% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * NESTED FUNCTION fCloseFigures (nested in imagine)
% * *
% * * Closes figures with special tag names
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fCloseFigures(hObject, eventdata) %#ok<*INUSD> eventdata is repeatedly unused
        % -----------------------------------------------------------------
        
        % Clear all the previous data
        %SData          = struct('imOrig',[],'imStack',[],'strROI',[]);
        
        fUpdateGUI();
        hFigs = findobj('Tag','SC');
        close(hFigs)
        
        % -----------------------------------------------------------------
        
    end


% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% * * NESTED FUNCTION fCloseGUI (nested in imagine)
% * *
% * * Figure callback
% * *
% * * Closes the figure and saves the settings
% * *
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fCloseGUI(hObject, eventdata) %#ok<*INUSD> eventdata is repeatedly unused
        % -----------------------------------------------------------------
        % close system
        try
            % clean final
            Par = SystemFinish(Par,true);
        catch
        end
        
        % save user params
        %fSaveGUI();
        
        % save ROI
        %fSessionSave();
        
        % close all figures
        hFigs = findobj('Tag','SC');
        close(hFigs)
        
        % -----------------------------------------------------------------
        %delete(hObject); % Bye-bye figure
        delete(hObject)
    end




end


