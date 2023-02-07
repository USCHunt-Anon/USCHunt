import matplotlib.pyplot as plt
import seaborn as sns

# load the iris dataset
data = sns.load_dataset('iris')

# view the dataset
rint(data.head(5))

# plotting histograms
plt.hist(data['petal_length'],
         label='petal_length')

plt.hist(data['sepal_length'],
         label='sepal_length')

plt.legend(loc='upper right')
plt.title('Overlapping')
plt.show()