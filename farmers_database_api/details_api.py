from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://likhithreddy:rylegand123@localhost/farmers_db'
db = SQLAlchemy(app)

class Farmer(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    mobile = db.Column(db.String(15), nullable=False)
    address = db.Column(db.String(200), nullable=False)

class Crop(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    farmer_id = db.Column(db.Integer, db.ForeignKey('farmer.id'), nullable=False)
    crop_name = db.Column(db.String(80), nullable=False)
    image_path = db.Column(db.String(200), nullable=False)
    total_acreage = db.Column(db.Float, nullable=False)
    drone_usage_acreage = db.Column(db.Float, nullable=False)
    products_used = db.Column(db.String(200), nullable=False)
    quantity_used = db.Column(db.Float, nullable=False)

@app.route('/register_farmer', methods=['POST'])
def register_farmer():
    data = request.json
    new_farmer = Farmer(name=data['name'], mobile=data['mobile'], address=data['address'])
    db.session.add(new_farmer)
    db.session.commit()
    return jsonify({'message': 'Farmer registered successfully', 'farmer_id': new_farmer.id}), 201

@app.route('/add_crop', methods=['POST'])
def add_crop():
    data = request.json
    new_crop = Crop(
        farmer_id=data['farmer_id'],
        crop_name=data['crop_name'],
        image_path=data['image_path'],
        total_acreage=data['total_acreage'],
        drone_usage_acreage=data['drone_usage_acreage'],
        products_used=data['products_used'],
        quantity_used=data['quantity_used']
    )
    db.session.add(new_crop)
    db.session.commit()
    return jsonify({'message': 'Crop added successfully'}), 201

@app.route('/get_crops/<int:farmer_id>', methods=['GET'])
def get_crops(farmer_id):
    crops = Crop.query.filter_by(farmer_id=farmer_id).all()
    return jsonify([{
        'id': crop.id,
        'crop_name': crop.crop_name,
        'image_path': crop.image_path,
        'total_acreage': crop.total_acreage,
        'drone_usage_acreage': crop.drone_usage_acreage,
        'products_used': crop.products_used,
        'quantity_used': crop.quantity_used
    } for crop in crops]), 200

@app.route('/get_crop/<int:crop_id>', methods=['GET'])
def get_crop(crop_id):
    crop = Crop.query.get(crop_id)
    if crop:
        return jsonify({
            'id': crop.id,
            'crop_name': crop.crop_name,
            'image_path': crop.image_path,
            'total_acreage': crop.total_acreage,
            'drone_usage_acreage': crop.drone_usage_acreage,
            'products_used': crop.products_used,
            'quantity_used': crop.quantity_used
        }), 200
    else:
        return jsonify({'message': 'Crop not found'}), 404

@app.route('/remove_crop/<int:crop_id>', methods=['DELETE'])
def remove_crop(crop_id):
    crop = Crop.query.get(crop_id)
    if crop:
        db.session.delete(crop)
        db.session.commit()
        return jsonify({'message': 'Crop removed successfully'}), 200
    else:
        return jsonify({'message': 'Crop not found'}), 404

@app.route('/get_drone_usage/<int:farmer_id>', methods=['GET'])
def get_drone_usage(farmer_id):
    crops = Crop.query.filter_by(farmer_id=farmer_id).all()
    total_drone_usage_acreage = sum(crop.drone_usage_acreage for crop in crops)
    per_acre_charge = 200  # Assuming the per acre charge is 200 INR
    total_amount = total_drone_usage_acreage * per_acre_charge
    return jsonify({
        'total_drone_usage_acreage': total_drone_usage_acreage,
        'total_amount': total_amount
    }), 200

@app.route('/get_farmer/<int:farmer_id>', methods=['GET'])
def get_farmer(farmer_id):
    farmer = Farmer.query.get(farmer_id)
    if farmer:
        return jsonify({
            'id': farmer.id,
            'name': farmer.name,
            'mobile': farmer.mobile,
            'address': farmer.address
        }), 200
    else:
        return jsonify({'message': 'Farmer not found'}), 404

if __name__ == '__main__':
    app.run(debug=True, host='192.168.1.4')