-- PostgreSQL database setup for Expense Tracker
-- Run these commands in PostgreSQL to set up the database

-- Create database
CREATE DATABASE expense_tracker;

-- Connect to the database
\c expense_tracker;

-- Create categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    color VARCHAR(7) DEFAULT '#2196F3',
    icon VARCHAR(50) DEFAULT 'category',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create expenses table
CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES categories(id),
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO categories (name, color, icon) VALUES
('Food & Dining', '#FF5722', 'restaurant'),
('Transportation', '#FF9800', 'directions_car'),
('Shopping', '#E91E63', 'shopping_cart'),
('Entertainment', '#9C27B0', 'movie'),
('Bills & Utilities', '#F44336', 'receipt'),
('Healthcare', '#4CAF50', 'local_hospital'),
('Travel', '#00BCD4', 'flight'),
('Education', '#3F51B5', 'school'),
('Personal Care', '#607D8B', 'spa'),
('Other', '#795548', 'more_horiz');

-- Create indexes for better performance
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category_id);
CREATE INDEX idx_expenses_created_at ON expenses(created_at);

-- Create a trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_expenses_updated_at 
    BEFORE UPDATE ON expenses 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();
