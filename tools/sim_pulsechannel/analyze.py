import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import cyclopts
from rich import print

# Set pandas to display all rows
pd.set_option('display.max_rows', None)

app = cyclopts.App()

@app.default
def main(
    csv: str, 
    col: str=" Max Error", 
    figname: str="results/analysis.png",
    drop_outliers: list=[],
    file: str | None = None,
):
    stat = analyze(csv, col=col, drop_outliers=drop_outliers)
    
    file = open(file, "w") if file else sys.stdout
    print(stat, file=file)

    plot(csv, col=col, figname=figname, drop_outliers=drop_outliers)

@app.command()
def analyze(csv: str, col: str=" Max Error", drop_outliers: list=[]) -> dict:
    data = pd.read_csv(csv)    
    
    # get the specific column
    df = data[col]
    
    # drop the outliers
    if drop_outliers:
        df = df.drop(drop_outliers)

    # Calculating basic statistics
    summary_statistics = df.describe()

    # Storing results in a dictionary for easy presentation
    statistics = {
        'Count': summary_statistics['count'],
        'Mean': summary_statistics['mean'],
        'Min': summary_statistics['min'],
        'Max': summary_statistics['max'],
        '25th Percentile (Q1)': summary_statistics['25%'],
        '50th Percentile (Median)': df.median(),
        '75th Percentile (Q3)': summary_statistics['75%'],
        'Mode': df.mode().iloc[0],
        'Range': df.max() - df.min(),
        'Variance': df.var(),
        'Standard Deviation': df.std()
    }
    
    return statistics

@app.command()
def plot(csv: str, stat: dict | None = None, col: str=" Max Error", figname: str="", drop_outliers: list=[]) -> None:
    if not stat:
        stat = analyze(csv, col, drop_outliers)
    
    data = pd.read_csv(csv)    
    
    # get the specific column
    df = data[col]
    
    # drop the outliers
    if drop_outliers:
        df = df.drop(drop_outliers)
    
    # Plotting the statistics summary

    fig, ax = plt.subplots(2, 2, figsize=(12, 10))

    # Boxplot to visualize quartiles and outliers
    ax[0, 0].boxplot(df, vert=False)
    ax[0, 0].set_title(f'Boxplot of {col}')
    ax[0, 0].set_xlabel(col)

    # Histogram to visualize the distribution of Max Error values
    ax[0, 1].hist(df, bins=15, edgecolor='black')
    ax[0, 1].set_title(f'Histogram of {col}')
    ax[0, 1].set_xlabel(col)
    ax[0, 1].set_ylabel('Frequency')

    # Line plot of sorted values to visualize trend
    ax[1, 0].plot(sorted(df), marker='o', linestyle='-', markersize=4)
    ax[1, 0].set_title(f'Trend of {col} (Sorted)')
    ax[1, 0].set_xlabel('Index (Sorted)')
    ax[1, 0].set_ylabel(col)

    # Bar chart to show key statistics (Mean, Median, Max, Min)
    stats_labels = ['Mean', 'Median', 'Max', 'Min', 'Std Dev']
    stats_values = [
        stat['Mean'], stat['50th Percentile (Median)'],
        stat['Max'], stat['Min'], stat['Standard Deviation']
    ]
    ax[1, 1].bar(stats_labels, stats_values, color='skyblue')
    ax[1, 1].set_title(f'Key Statistics of {col}')
    ax[1, 1].set_ylabel('Value')

    plt.tight_layout()
    
    # save the figure if a filename is provided
    if figname:
        plt.savefig(figname)
    else:
        plt.show()
    
if __name__ == "__main__":
    sys.exit(app())

