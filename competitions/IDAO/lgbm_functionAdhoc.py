

import utils_train as utils
import scoring


def error_idao(y_pred_proba, data):
    import scoring
    y_real = data.get_label()
    sample_weight = data.get_weight()
    score = scoring.rejection90(y_real, y_pred_proba, sample_weight)
    return ('error_idao', score , True)
	

#características y target
X = train[features_to_model] # mis variables predictoras
y = train[TARGET] # mi variable target
y_weights = train['weight'] # los pesos de cada registro


from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test, y_weights_train, y_weights_test = train_test_split(X, y.values, y_weights.values, 
                                                                                     test_size=0.30, 
                                                                                     random_state=42)

	
import lightgbm as lgb
lgb_train = lgb.Dataset(X_train, label =y_train, weight = y_weights_train)
lgb_eval = lgb.Dataset(X_test, label = y_test, weight = y_weights_test)       


dicc_results = {}
model_lgbm = lgb.train(lgb_params, 
                  lgb_train,
                  num_boost_round= 1000,
                  valid_names = ["ds_train","ds_valid"], ## nombres cualquiera
                  valid_sets = [lgb_train,lgb_eval],
                  early_stopping_rounds = 100, 
                  feval = error_idao,
                  evals_result = dicc_results,
                  verbose_eval = 0)
				  
				  
## Predict
y_pred_train_proba = model.predict(X_train, num_iteration=model.best_iteration)
y_pred_test_proba = model.predict(X_test, num_iteration=model.best_iteration)
				  

## Medir
				  
rejection90_train = scoring.rejection90(y_train, y_pred_train_proba, sample_weight=y_weights_train)
rejection90_valid = scoring.rejection90(y_test, y_pred_test_proba, sample_weight=y_weights_test)

print("REJ train: ",rejection90_train)
print("REJ test : ",rejection90_valid)

metric_train = mt.roc_auc_score(y_train, y_pred_train_proba, sample_weight=y_weights_train)
metric_valid = mt.roc_auc_score(y_test, y_pred_test_proba, sample_weight=y_weights_test)

print("\nROC train: ",metric_train)
print("ROC test : ",metric_valid)