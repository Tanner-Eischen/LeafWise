import os, sys, traceback
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from importlib import import_module

def probe():
    try:
        saz = import_module('app.schemas.seasonal_ai')
        targets = [
            'SizeProjection', 'FloweringPeriod', 'DormancyPeriod', 'GrowthForecast',
            'CareAdjustment', 'RiskFactor', 'PlantActivity', 'GrowthPhase',
            'SeasonalPrediction', 'CareAdjustmentResponse', 'CustomPredictionResponse',
            'SeasonalPredictionListResponse', 'SeasonalTransitionResponse'
        ]
        for name in targets:
            cls = getattr(saz, name)
            print(f'-- probing {name} --')
            try:
                _ = cls.model_json_schema()
                print(f'{name}: OK')
            except Exception as e:
                print(f'{name}: ERROR {type(e).__name__}: {e!r}')
                traceback.print_exc()
                break
    except Exception as e:
        print('Import seasonal_ai failed:', repr(e))
        traceback.print_exc()

if __name__ == '__main__':
    probe()