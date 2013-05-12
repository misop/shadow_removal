function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 08-May-2013 02:49:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)
loadImg(handles,'../img/5.png');
showMask(handles,0);
showContours(handles,0);

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function btnSelectImg_Callback(hObject, eventdata, handles)
[FileName PathName] = uigetfile('../img/*','Select Image');
if (isequal(PathName,0))
    return;
end
loadImg(handles, fullfile(PathName,FileName));



function loadImg(handles, path)
global img;
img = imread(path);
%tileSize = str2num(get(handles.edit1, 'String'));
%img = clipEdges(img, tileSize);
axes(handles.axes1);
imshow(img);



function showMask(handles, maskImg)
axes(handles.axes2);
imshow(maskImg*255);

function showContours(handles, contours)
axes(handles.axes3);
imshow(contours);



function btnCompute_Callback(hObject, eventdata, handles)
global img;
global intr;
waitStart(handles);

theta = str2double(get(handles.edit1, 'String'));
[intr, theta] = getIntrinsic(img, 1, 0.00001, true, true, theta);
set(handles.edit2, 'String', int2str(theta));

slider2_Callback(hObject, eventdata, handles);
waitDone(handles);
figure; imshow(intr);

function btnCompute_Callback2_Callback(hObject, eventdata, handles)
global img;
global intr;
waitStart(handles);

theta = str2double(get(handles.edit1, 'String'));
[intr, theta] = getIntrinsic(img, 2, 0.00001, true, true, theta);
set(handles.edit2, 'String', int2str(theta));

slider2_Callback(hObject, eventdata, handles);
waitDone(handles);
figure; imshow(intr);


function waitStart(handles)
set(handles.txtWait, 'String', 'Please wait...');
drawnow();

function waitDone(handles)
set(handles.txtWait, 'String', '');
drawnow();



function btnCloseAll_Callback(hObject, eventdata, handles)
h = findall(0,'type','figure');
h1 = handles.figure1;
h(find(h==h1))=[];
close(h);



function slider2_Callback(hObject, eventdata, handles)
global img;
global intr;
global mask;
val = get(handles.slider2, 'Value');
G = rgb2gray(img);
mask = intr - G*val;
treshold = 25;
mask(mask<treshold) = 0;
mask(mask>=treshold) = 1;
[mask contours] = smoothShadowMask(img, mask);
showMask(handles, mask);
showContours(handles, contours);



function btnRemoveShadow_Callback(hObject, eventdata, handles)
global img;
global mask;
removeShadow(img, mask, get(handles.checkbox1, 'Value'));




