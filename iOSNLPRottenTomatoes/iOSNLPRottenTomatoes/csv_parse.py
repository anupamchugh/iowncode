import os
import pandas as pd
df = pd.read_csv("rotten_tomatoes_reviews.csv", nrows=20000)
df.columns = ["freshness", "review"]
# Split data into training and testing sets by label
train = df.sample(frac=0.8, random_state=42)
train_good = train[train.freshness == 1]
train_bad = train.drop(train_good.index)
test = df.drop(train.index)
test_good = test[test.freshness == 1]

test_bad = test.drop(test_good.index)
# Create folders for data
os.mkdir("train"); os.mkdir("test")
os.mkdir("train/good"); os.mkdir("train/bad")
os.mkdir("test/good"); os.mkdir("test/bad")
#Write out data
def write_text(path, df):
    for i, r in df.iterrows():
        with open(path + str(i) + ".txt", "w") as f:
            f.write(r["review"])
write_text("train/good/", train_good)
write_text("train/bad/", train_bad)
write_text("test/good/", test_good)
write_text("test/bad/", test_bad)
