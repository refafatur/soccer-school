const jwt = require('jsonwebtoken');
const { secret } = require('../config/jwt.config');

const verifyToken = (req, res, next) => {
  const bearerHeader = req.headers['authorization'];
  
  if (!bearerHeader) {
    return res.status(401).json({ 
      status: 'error',
      message: 'Token tidak ditemukan' 
    });
  }

  try {
    const bearer = bearerHeader.split(' ');
    const token = bearer[1];
    const decoded = jwt.verify(token, secret);
    
    req.user = decoded;
    console.log('Decoded token:', decoded); // Debug decoded token
    
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(401).json({ 
      status: 'error',
      message: 'Token tidak valid' 
    });
  }
};

module.exports = { verifyToken }; 