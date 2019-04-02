from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_samples, silhouette_score

import matplotlib.pyplot as plt
import matplotlib.cm as cm
import seaborn as sns
sns.set(style="whitegrid")
import numpy as np
import pandas as pd

from utils import get_default_args

def graph_analysis_best_number_cluster(X, range_n_clusters=range(2,11)):
    for n_clusters in range_n_clusters:
        # Create a subplot with 1 row and 2 columns
        fig, (ax1, ax2) = plt.subplots(1, 2)
        fig.set_size_inches(18, 7)

        ax1.set_xlim([-0.1, 1])
        ax1.set_ylim([0, len(X) + (n_clusters + 1) * 10])

        clusterer = KMeans(n_clusters=n_clusters, random_state=10)
        cluster_labels = clusterer.fit_predict(X)

        silhouette_avg = silhouette_score(X, cluster_labels, sample_size=300)
        print("For n_clusters =", n_clusters,
              "The average silhouette_score is :", silhouette_avg)

        sample_silhouette_values = silhouette_samples(X, cluster_labels)

        y_lower = 10
        for i in range(n_clusters):
            ith_cluster_silhouette_values = \
                sample_silhouette_values[cluster_labels == i]

            ith_cluster_silhouette_values.sort()

            size_cluster_i = ith_cluster_silhouette_values.shape[0]
            y_upper = y_lower + size_cluster_i

            color = cm.nipy_spectral(float(i) / n_clusters)
            ax1.fill_betweenx(np.arange(y_lower, y_upper),
                              0, ith_cluster_silhouette_values,
                              facecolor=color, edgecolor=color, alpha=0.7)

            ax1.text(-0.05, y_lower + 0.5 * size_cluster_i, str(i))
            y_lower = y_upper + 10

        ax1.set_title("The silhouette plot for the various clusters.")
        ax1.set_xlabel("The silhouette coefficient values")
        ax1.set_ylabel("Cluster label")

        # Se dibuja la linea vertical del valor promedio de la silueta
        ax1.axvline(x=silhouette_avg, color="red", linestyle="--")

        ax1.set_yticks([])  # Clear the yaxis labels / ticks
        ax1.set_xticks([-0.1, 0, 0.2, 0.4, 0.6, 0.8, 1])

        # 2nd Plot showing the actual clusters formed
        colors = cm.nipy_spectral(cluster_labels.astype(float) / n_clusters)
        ax2.scatter(X[:, 0], X[:, 1], marker='.', s=30, lw=0, alpha=0.7,
                    c=colors, edgecolor='k')

        # Labeling the clusters
        centers = clusterer.cluster_centers_
        # Draw white circles at cluster centers
        ax2.scatter(centers[:, 0], centers[:, 1], marker='o',
                    c="white", alpha=1, s=200, edgecolor='k')

        for i, c in enumerate(centers):
            ax2.scatter(c[0], c[1], marker='$%d$' % i, alpha=1,
                        s=50, edgecolor='k')

        ax2.set_title("The visualization of the clustered data.")
        ax2.set_xlabel("Feature space for the 1st feature")
        ax2.set_ylabel("Feature space for the 2nd feature")

        plt.suptitle(("Silhouette analysis for KMeans clustering on sample data "
                      "with n_clusters = %d" % n_clusters),
                     fontsize=14, fontweight='bold')

        plt.show()

def graphs_analysis(data, col_init, col_out, **kwargs):
    color_label = kwargs.get('color_label', 'black')
    params_default = get_default_args(pd.value_counts)
    
    params_default = {
        k:v for k, v in {**params_default, **kwargs}.items() if k in params_default
    }
    
    print(pd.DataFrame(data[col_init]).corrwith(data[col_out]))
    
    fig, axes = plt.subplots(nrows=2, ncols=2)
    graphs = [
        data[col_init].value_counts(**params_default).plot(ax=axes[0,0], figsize=(15,10)),
        data[col_init].value_counts(**params_default).plot.bar(ax=axes[0,1]),
        sns.lineplot(x=col_init, y=col_out, data=data, ax=axes[1,0]),
        sns.barplot(x=col_init, y=col_out, data=data, ax=axes[1,1])
    ]
    for _ in graphs:
        _.xaxis.label.set_color(color_label)
        _.yaxis.label.set_color(color_label)
        _.tick_params(colors=color_label)

def plot_2d_point(axis_0=[], axis_1=[], color_label=''):
    color_label = color_label or 'black'
    clusters_df = pd.DataFrame( { "axis_0":axis_0, "axis_1": axis_1 } )
    _ = sns.lineplot(x=axis_0, y=axis_1, data=clusters_df)
    _.xaxis.label.set_color(color_label)
    _.yaxis.label.set_color(color_label)
    _.tick_params(colors=color_label)


def simple_get_siluet_score(X, cluster_range = range( 2, 15 )):
    list_silhouette = []
    for n_clusters in cluster_range:
        clusterer = KMeans(n_clusters=n_clusters, random_state=10, n_jobs=4, max_iter=750)
        cluster_labels = clusterer.fit_predict(X)
        list_silhouette.append(
            silhouette_score(X, cluster_labels, sample_size=300)
        )
        print("For n_clusters =", n_clusters,
              "The average silhouette_score is :", list_silhouette[-1])
        
    plot_2d_point(cluster_range, list_silhouette, color_label='skyblue')

def get_inertia(X, cluster_range = range( 2, 15 )):
    list_intertia = []
    for num_clusters in cluster_range:
        clusters_km = KMeans(num_clusters)
        clusters_km.fit(X)
        list_intertia.append(clusters_km.inertia_)
        print("For n_clusters =", num_clusters,
              "The inertia is :", list_intertia[-1])
        
    plot_2d_point(cluster_range, list_intertia, color_label='skyblue')


def graphs_box_disp(serie, **kwargs):
    color_label = kwargs.get('color_label', 'black')
    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(15,5))
    graphs = [
        sns.boxplot(x=serie, ax=axes[0]),
        sns.distplot(serie, kde=True, rug=False, bins=100, ax=axes[1])
    ]
    for _ in graphs:
        _.xaxis.label.set_color(color_label)
        _.tick_params(colors=color_label)


def flash_analysis(data, col_init, col_out, **kwargs):
    color_label = kwargs.get('color_label', 'black')
    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(15, 5))
    
    cross = pd.crosstab(data[col_out], data[col_init])
    sum_total = sum([cross[col].sum() for col in cross.columns])
    sns.heatmap(
        cross/sum_total, 
        annot=True, ax=axes[0], center=0, cmap="YlGnBu", fmt='.2%'
    )
    sns.barplot(
        x=col_init, y=col_out, data=data, ax=axes[1]
    )

def flash_numeric(data, col_init, col_out, **kwargs):
    color_label = kwargs.get('color_label', 'black')
    bins = kwargs.get('bins', 3)
    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(15, 5))

    sns.violinplot(x=col_out, y=col_init, data=data, ax=axes[0])
    sns.lineplot(x=col_init, y=col_out, data=data, ax=axes[1])




     