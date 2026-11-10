% Exp 4: MTI Radar using Delay Line Canceller (Step-by-Step Signals)
clear; clc; close all;

%% 1. Parameters Setup
num_pulses = 100;         % Number of pulse repetitions (Slow-time)
num_bins = 200;           % Range bins per pulse (Fast-time)

%% 2. Generate Radar Signals
rx_signal = 0.1 * (randn(num_pulses, num_bins) + 1i * randn(num_pulses, num_bins));

% Range positions
clutter_pos = 50;         % Stationary clutter
stat_target_pos = 90;     % Stationary target
moving_target_pos = 150;  % Moving target

% Populate target data across pulses
t = (1:num_pulses)';
doppler_shift = 0.15;

rx_signal(:, clutter_pos) = rx_signal(:, clutter_pos) + 10;
rx_signal(:, stat_target_pos) = rx_signal(:, stat_target_pos) + 5;
rx_signal(:, moving_target_pos) = rx_signal(:, moving_target_pos) + ...
    3 * exp(1i * 2 * pi * doppler_shift * t);

%% 3. Step-by-Step Signal Extraction (Using Pulses #10 and #11 as example)
pulse_idx_current = 11;
pulse_idx_delayed = 10;
pulse_current = rx_signal(pulse_idx_current, :);   % Pulse n (complex, fast-time snapshot)
pulse_delayed = rx_signal(pulse_idx_delayed, :);   % Pulse n-1 (Delayed pulse)
pulse_diff = pulse_current - pulse_delayed;        % Complex difference signal

%% 4. Process Full MTI Output
mti_signal = rx_signal(2:end, :) - rx_signal(1:end-1, :);

%% 5A. NEW: Range-Pulse Map showing the Delay Line concept prominently
figure('Name', 'Delay Line Concept - Range/Pulse Map', 'Position', [100, 50, 950, 500]);
imagesc(1:num_bins, 1:num_pulses, abs(rx_signal));
set(gca, 'YDir', 'normal');
colormap(gca, 'parula');
colorbar;
xlabel('Range Bin (Fast-time)');
ylabel('Pulse Number (Slow-time)');
title('Received Signal: Pulse History (rows) vs Range Bin (columns)');
hold on;

% Highlight the two pulses being compared
yline(pulse_idx_current, 'r-', 'LineWidth', 2);
yline(pulse_idx_delayed, 'm-', 'LineWidth', 2);

% Annotate the delay gap with a double-headed arrow between the two rows
annotation_x = num_bins + 5; % just outside plot area conceptually; we use text+line inside axes instead
line([num_bins*0.92, num_bins*0.92], [pulse_idx_delayed, pulse_idx_current], ...
    'Color', 'w', 'LineWidth', 2);
plot(num_bins*0.92, pulse_idx_delayed, 'w^', 'MarkerFaceColor', 'w', 'MarkerSize', 6);
plot(num_bins*0.92, pulse_idx_current, 'wv', 'MarkerFaceColor', 'w', 'MarkerSize', 6);
text(num_bins*0.94, mean([pulse_idx_delayed, pulse_idx_current]), ...
    '1 Pulse Delay (T)', 'Color', 'w', 'FontSize', 9, 'FontWeight', 'bold');

legend({'Pulse #11 (x[n], current)', 'Pulse #10 (x[n-1], delayed)'}, ...
    'TextColor', 'w', 'Color', 'k', 'Location', 'southoutside', 'Orientation', 'horizontal');
hold off;

%% 5B. Plotting the Steps
figure('Name', 'MTI Delay Line Canceller Steps', 'Position', [150, 50, 950, 750]);

% Step 1: Current Received Pulse x[n]
subplot(4, 1, 1);
mag_current = abs(pulse_current);
plot(mag_current, 'r', 'LineWidth', 1.2);
title('Step 1: Current Pulse x[n] (Pulse #11)');
ylabel('Amplitude'); grid on;
ylim([0, max(mag_current)*1.3]);
text(clutter_pos, mag_current(clutter_pos)+0.8, '\leftarrow Clutter', 'FontSize', 8);
text(stat_target_pos, mag_current(stat_target_pos)+0.8, '\leftarrow Stat. Target', 'FontSize', 8);
text(moving_target_pos, mag_current(moving_target_pos)+0.8, '\leftarrow Moving Target', 'FontSize', 8);

% Step 2: Delayed Pulse x[n-1]
subplot(4, 1, 2);
mag_delayed = abs(pulse_delayed);
plot(mag_delayed, 'm', 'LineWidth', 1.2);
title('Step 2: Delayed Pulse x[n-1] (Pulse #10)');
ylabel('Amplitude'); grid on;
ylim([0, max(mag_current)*1.3]);  % same scale as Step 1 for fair comparison

% Step 2.5 overlay note: show current vs delayed together to visualize the shift
hold on;
plot(mag_current, 'r--', 'LineWidth', 0.8);
legend({'x[n-1] (delayed)', 'x[n] (current, ref.)'}, 'Location', 'northeast', 'FontSize', 7);
hold off;

% Step 3: Difference Signal x[n] - x[n-1] for Single Pair
subplot(4, 1, 3);
mag_diff = abs(pulse_diff);
plot(mag_diff, 'k', 'LineWidth', 1.2);
title('Step 3: Difference Signal y[n] = x[n] - x[n-1] (Single Delay Line Output)');
ylabel('Amplitude'); grid on;
ylim([0, max(mag_current)*1.3]);

% Step 4: Final Averaged Output across all pulses
subplot(4, 1, 4);
mag_final = mean(abs(mti_signal), 1);
plot(mag_final, 'b', 'LineWidth', 1.5);
title('Step 4: Final MTI Output (Averaged across all processed pulses)');
xlabel('Range Bin'); ylabel('Amplitude'); grid on;
ylim([0, max(mag_final)*1.5]);
text(moving_target_pos, mag_final(moving_target_pos)+0.3, '\leftarrow Only Moving Target Detected', 'FontSize', 8);