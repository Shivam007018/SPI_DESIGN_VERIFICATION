SPI_SV
SPI is a high-speed, full-duplex serial communication protocol used to transfer data between microcontrollers and peripherals like sensors, memory devices, or ADC/DACs. It was developed by Motorola and is widely used in embedded systems for short-distance communication.

How SPI Works: The master generates the clock (SCLK) and initiates communication. Data is shifted in and out simultaneously through MOSI and MISO. The clock polarity (CPOL) and clock phase (CPHA) determine when data is sampled. Multiple slaves can be supported using separate SS lines.

Key Features of SPI: Full-duplex transmission (both directions simultaneously) Faster than I2C for short-range communication. Simple hardware interface (no address needed) ,Easy to implement in SystemVerilog/Verilog

<img width="909" height="458" alt="Screenshot 2025-08-05 132611" src="https://github.com/user-attachments/assets/cd56ecc3-053e-444c-824b-409e2576b0ee" />
<img width="369" height="317" alt="Screenshot 2025-08-05 145015" src="https://github.com/user-attachments/assets/7d80d68c-339d-4250-9e4f-be7ef82eef65" />
