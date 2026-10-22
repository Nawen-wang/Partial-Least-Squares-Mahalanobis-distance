
% Visualization for PLS regression
[XL,yl,XS, YS,beta,PCTVAR,MSE,stats] = plsregress(behavior, test(:,1), 3);
gscatter(XS(:,1),XS(:,2), SG)

% Calculate Mahalanobis distance
XS_SG = XS(SG==1, :);
XS_HH = XS(SG==0,:);
dis = mahal(XS_SG, XS_HH);

% Linear mixed-effects model setup
T = table();
T.sex = grooming_sex;
T.group = grooming_group;
T.grooming = grooming;
T.emo = dis;
lme = fitlme(T, 'emo ~ grooming+sex+(1|group)', 'FitMethod', 'REML');

% Distance adjusted for covariates
dis_predict = predict(lme);
[r,p]=corrcoef(grooming, dis_predict);

figure('Position', [100 100 800 600], 'Color', 'w');
% Scatter plot grouped by sex (X = grooming, Y = corrected distance)
% Extract sex labels
sex_values = T.sex;
idx_female = sex_values == 0;  % Female, coded as 0
idx_male = sex_values == 1;    % Male, coded as 1

% Scatter plot for females (sex = 0)
scatter(grooming(idx_female), dis_predict(idx_female), 80, [0.8 0.2 0.2], 'filled', ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k', 'LineWidth', 1, ...
    'DisplayName', 'Sex = 0 (Female)');
hold on;

% Scatter plot for males (sex = 1)
scatter(grooming(idx_male), dis_predict(idx_male), 80, [0.2 0.2 0.8], 'filled', ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k', 'LineWidth', 1, ...
    'DisplayName', 'Sex = 1 (Male)');

% Global regression line for all observations
p_fit = polyfit(grooming, dis_predict, 1);
x_line = linspace(min(grooming), max(grooming), 100);
y_line = polyval(p_fit, x_line);
plot(x_line, y_line, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Overall Fit');

% Optional: Regression lines stratified by sex
% Regression line for female group
if sum(idx_female) > 1
    p_fit_female = polyfit(grooming(idx_female), dis_predict(idx_female), 1);
    y_line_female = polyval(p_fit_female, x_line);
    plot(x_line, y_line_female, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Female Fit');
end
% Regression line for male group
if sum(idx_male) > 1
    p_fit_male = polyfit(grooming(idx_male), dis_predict(idx_male), 1);
    y_line_male = polyval(p_fit_male, x_line);
    plot(x_line, y_line_male, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Male Fit');
end

% Correlation statistics for the full sample
[r_all, p_all] = corrcoef(grooming, dis_predict);
text(max(grooming)*0.65, max(dis_predict)*0.92, ...
    sprintf('Overall: r = %.3f, p = %.4f', r_all(2), p_all(2)), ...
    'FontSize', 11, 'FontWeight', 'bold', ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', ...
    'HorizontalAlignment', 'center');

% Correlation statistics for female subgroup
[r_female, p_female] = corrcoef(grooming(idx_female), dis_predict(idx_female));
text(max(grooming)*0.65, max(dis_predict)*0.80, ...
    sprintf('Female (0): r = %.3f, p = %.4f', r_female(2), p_female(2)), ...
    'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k', ...
    'HorizontalAlignment', 'center');

% Correlation statistics for male subgroup
[r_male, p_male] = corrcoef(grooming(idx_male), dis_predict(idx_male));
text(max(grooming)*0.65, max(dis_predict)*0.70, ...
    sprintf('Male (1): r = %.3f, p = %.4f', r_male(2), p_male(2)), ...
    'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k', ...
    'HorizontalAlignment', 'center');

% Sample size annotation
text(max(grooming)*0.65, max(dis_predict)*0.60, ...
    sprintf('n_total = %d\nn_female = %d\nn_male = %d', ...
    length(grooming), sum(idx_female), sum(idx_male)), ...
    'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k', ...
    'HorizontalAlignment', 'center');

% Axis labels and figure title
xlabel('Grooming Time', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Corrected Distance (dis\_predict)', 'FontSize', 12, 'FontWeight', 'bold');
title('Correlation: Grooming Time vs Corrected Distance (by Sex)', ...
    'FontSize', 13, 'FontWeight', 'bold');

% Legend
legend('Location', 'best', 'FontSize', 10);

% Figure aesthetic settings
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1.2);


