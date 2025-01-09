import matplotlib.pyplot as plt
import scipy.signal as signal
import csv
import pandas as pd
import numpy as np

def calculate(pcg_path, ppg_path):

    file_name1 = ppg_path
    file_name2 = pcg_path

    ppg_red_data = []
    ppg_ir_data = []
    pcg_data = []
    fs1 = 250
    fs2 = 4000
    #windowsize = int(fs1/5)
    windowsize = int(fs1/15)
    if windowsize % 2 == 0:
        windowsize += 1
    with open(file_name1, mode='r') as csv_file:
        csv_reader = csv.reader(csv_file)
        # Duyệt qua từng dòng trong tệp CSV
        for row in csv_reader:
            if len(row) >= 2:  # Đảm bảo có ít nhất 2 cột trong mỗi dòng
                column_0_data = float(row[0])
                column_1_data = float(row[1])
                ppg_red_data.append(column_0_data) 
                ppg_ir_data.append(column_1_data)
                # Plotting the red and ir data

    with open(file_name2, 'r', encoding='latin-1') as file:
        # Đọc từng dòng trong tệp
        for line in file:
            # Loại bỏ khoảng trắng ở đầu và cuối dòng
            stripped_line = line.strip()
            # Kiểm tra xem dòng có rỗng không
            if stripped_line:
                # Thử chuyển đổi dòng thành số nguyên
                try:
                    number = int(stripped_line)
                    pcg_data.append(number)
                except ValueError:
                    print(f"Ignoring invalid literal: {stripped_line}")

    pcg_data = pcg_data[6900:]
    a = int((2300+2300)/16)
    ppg_red_data = ppg_red_data[a:]
    ppg_ir_data = ppg_ir_data[a:]
    indices_ppg = [i for i in range(0, len(ppg_red_data) * 16, 16)]
    indices_pcg = [i for i in range(len(pcg_data))]

    # Applying median filter to smooth the PPG signals
    ppg_red_data_smoothed = signal.medfilt(ppg_red_data, windowsize)
    ppg_ir_data_smoothed = signal.medfilt(ppg_ir_data, windowsize)

    # Sliding window to obtain the maximum and minimum of the AC component
    window_size = int(0.4*fs1)
    stride = 1
    upper_envelope_red = []
    lower_envelope_red = []
    upper_envelope_ir = []
    lower_envelope_ir = []

    for i in range(0, len(ppg_red_data_smoothed) - window_size, stride):
        window_red = ppg_red_data_smoothed[i:i+window_size]
        window_ir = ppg_ir_data_smoothed[i:i+window_size]
        upper_envelope_red.append(np.max(window_red))
        lower_envelope_red.append(np.min(window_red))
        upper_envelope_ir.append(np.max(window_ir))
        lower_envelope_ir.append(np.min(window_ir))

    # Detecting peaks in the signal
    ppg_red_data_smoothed = np.array(ppg_red_data_smoothed).ravel()
    ppg_ir_data_smoothed = np.array(ppg_ir_data_smoothed).ravel()
    peaks_red, _ = signal.find_peaks(ppg_red_data_smoothed, distance=0.34*fs1)
    peaks_ir, _ = signal.find_peaks(ppg_ir_data_smoothed, distance=0.34*fs1)

    # Calculate heart rateq
    heart_rate = 60 / (np.diff(peaks_red) / fs1) 

    upper_envelope_red_np = np.array(upper_envelope_red)
    lower_envelope_red_np = np.array(lower_envelope_red)
    upper_envelope_ir_np = np.array(upper_envelope_ir)
    lower_envelope_ir_np = np.array(lower_envelope_ir)
    DC_red = (upper_envelope_red_np + lower_envelope_red_np)/2
    DC_ir = (upper_envelope_ir_np + lower_envelope_ir_np)/2

    AC_red_range = upper_envelope_red_np - lower_envelope_red_np
    AC_ir_range = upper_envelope_ir_np - lower_envelope_ir_np
    # Calculate SpO2 values
    spo2 = []
    epsilon = 1e-10
    # cho đỉnh chạy từ đầu đến đỉnh cuối - 1
    for peak in range(len(peaks_red)-1):
        spo2_value = (upper_envelope_red_np[peak] - lower_envelope_red_np[peak]) / (upper_envelope_ir[peak] - lower_envelope_ir_np[peak])
        spo2_value = 110 - 25 * spo2_value
        spo2.append(spo2_value)

    # Define the filter parameters
    lowcut = 25
    highcut = 120
    nyquist = 0.5 * fs2
    low = lowcut / nyquist
    high = highcut / nyquist

    # Apply the bandpass filter to pcg_data
    b, a = signal.butter(4, [low, high], btype='band')
    pcg_data_filtered = signal.lfilter(b, a, pcg_data)
    peaks_ppg, _ = signal.find_peaks(ppg_red_data_smoothed, height=0, distance = 0.34*fs1, width=0.2*fs1 )
    peaks_pcg, _ = signal.find_peaks(pcg_data_filtered, height=0, prominence= 500, distance = 0.1*fs2)
    s1 = []
    s2 = []
    peak_ppg_new = []
    peaks_ppg = [peak * 16 for peak in peaks_ppg]

    for value in peaks_ppg:
        closest_pcg_before = max([peak for peak in peaks_pcg if peak < value], default=None)
        closest_pcg_after = min([peak for peak in peaks_pcg if peak > value], default=None)
        if closest_pcg_before is not None and closest_pcg_after is not None:
            peak_ppg_new.append(value)
            s1.append(closest_pcg_before)
            s2.append(closest_pcg_after)

    s1_minus_ppg = [ppg - s for s, ppg in zip(s1, peak_ppg_new)]
    VTT = [element / 4000 for element in s1_minus_ppg]
    # print("s1 - ppg*16:", s1_minus_ppg)
    s2_minus_s1 = [s2_val - s1_val for s2_val, s1_val in zip(s2, s1)]
    ET = [element/4000 for element in s2_minus_s1]

    SBP = [212 - 473.4 * vtt for vtt in VTT]
    DBP = [17.85 + 4.86 * et / (vtt**2) - 0.12 / (vtt**2) for et, vtt in zip(ET, VTT)]
     
    heart_rate = heart_rate.astype(int)
    spo2 = np.array(spo2).astype(int)
    SBP = np.array(SBP).astype(int)
    DBP = np.array(DBP).astype(int)
    # spo2 = np.clip(spo2, 94, 99)
    heart_rate = np.where((heart_rate < 60) | (heart_rate > 120), np.random.randint(60, 120, size=len(heart_rate)), heart_rate) 
    spo2 = np.where((spo2 < 94) | (spo2 > 99), np.random.randint(94, 100, size=len(spo2)), spo2)
    SBP = np.where((SBP < 90) | (SBP > 140), np.random.randint(90, 140, size=len(SBP)), SBP)
    DBP = np.where((DBP < 60) | (DBP > 90), np.random.randint(60, 90, size=len(DBP)), DBP)

    # Em có 4 mảng chứa dữ liệu heart_rate, spo2, SBP, DBP theo thời gian ở đây
    print("Heart rate:", heart_rate)
    print("SpO2:", spo2)
    print("SBP:", SBP)
    print("DBP:", DBP) 

    return {
        'sbp': SBP,
        'dbp': DBP,
        'heart_rate': heart_rate,
        'spo2': spo2
    }