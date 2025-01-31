# Income Statement Project

## Índice
- [Descripción del Proyecto](#descripción-del-proyecto)
- [Consultas SQL](#consultas-sql)
  - [Balance Sheet](#balance-sheet)
  - [Income Statement](#income-statement)
  - [Secciones del Balance General](#secciones-del-balance-general)
  - [Cuentas Utilizadas](#cuentas-utilizadas)
- [Consideraciones Adicionales](#consideraciones-adicionales)
- [Conclusión](#conclusión)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)

## Descripción del Proyecto

Este proyecto facilita la generación automatizada de informes financieros clave, permitiendo a analistas y empresas obtener información precisa y en tiempo real sobre su estado financiero. Utilizando SQL, se crean vistas materializadas optimizadas para obtener rápidamente el balance general y el estado de resultados, con la posibilidad de extraer métricas como el ratio de liquidez y el margen bruto.

## Consultas SQL

### Balance Sheet

Esta consulta crea una vista materializada que combina las secciones de activos, pasivos y patrimonio neto para generar el balance general. El balance general es una instantánea de la situación financiera de la empresa en un momento dado, mostrando lo que la empresa posee (activos), lo que debe (pasivos) y el capital de los propietarios (patrimonio neto).

**Consulta SQL:**
```sql
CREATE MATERIALIZED VIEW balance_sheet AS
WITH balance_sheet AS (
    SELECT * FROM section_assets
    UNION ALL
    SELECT * FROM section_liabilities
    UNION ALL
    SELECT * FROM section_owners_equity
)
SELECT * FROM balance_sheet;
```

**Ejemplo de Salida:**
| Period Year | Section       | Account                     | Total Amount |
|-------------|---------------|-----------------------------|-------------:|
| 2021        | Assets        | Cash                        | 328,461.77   |
| 2021        | Assets        | Accounts Receivable         | 65,872.21    |
| 2021        | Assets        | Inventory                   | 1,149,234.55 |
| 2021        | Assets        | Property, Land and Equipment| 39,250.00    |
| 2021        | Assets        | Assets                      | 1,582,818.53 |
| 2021        | Liabilities   | Loan                        | 1,196,666.67 |
| 2021        | Liabilities   | Liabilities                 | 1,196,666.67 |
| 2021        | Owners Equity | Owners Equity               | 386,151.86   |
| 2021        | Owners Equity | Retained Earnings           | 386,151.86   |

### Income Statement

Esta consulta genera el estado de resultados, que muestra los ingresos, gastos y ganancias de la empresa durante un período específico. Es fundamental para evaluar la rentabilidad y el desempeño financiero de la empresa.

**Consulta SQL:**
```sql
CREATE MATERIALIZED VIEW income_statement AS
SELECT period_year,
       CASE WHEN transaction_type = 'Retained Earnings' THEN 'Net Income'
            ELSE transaction_type
       END AS transaction_type,
       total_amount
FROM account_retained_earnings_details;
```

**Ejemplo de Salida:**
| Period Year | Transaction Type                  | Total Amount |
|-------------|-----------------------------------|-------------:|
| 2021        | Retained Earnings - Beginning Balance | 0.00     |
| 2021        | Revenue                           | 1,603,800.21 |
| 2021        | Cost of Goods Sold                | -1,062,231.69|
| 2021        | Depreciation                      | 8,250.00     |
| 2021        | Tax Expeses                       | -15,000.00   |
| 2021        | Interest Expeses                  | -20,666.66   |
| 2021        | Wage Expeses                      | -69,000.00   |
| 2021        | Operational Expeses               | -59,000.00   |
| 2021        | Net Income                        | 386,151.86   |

### Secciones del Balance General

Para construir el balance general, se utilizan varias vistas materializadas que representan diferentes secciones del balance:

- **Section Assets**: Representa los activos de la empresa. [Consulta SQL](./workflow/section_assets.sql)
- **Section Liabilities**: Representa los pasivos de la empresa. [Consulta SQL](./workflow/section_liabiliies.sql)
- **Section Owners Equity**: Representa el patrimonio de los propietarios. [Consulta SQL](./workflow/section_owners_equity.sql)

### Cuentas Utilizadas

Las siguientes consultas SQL crean las vistas materializadas para las cuentas utilizadas en las secciones del balance general y el estado de resultados:

- **Account Cash**: Representa el efectivo de la empresa. Esta cuenta es crucial para entender la liquidez inmediata de la empresa, es decir, su capacidad para cumplir con obligaciones a corto plazo. [Consulta SQL](./workflow/cash_account.sql)
- **Account Accounts Receivable**: Representa las cuentas por cobrar. Esta cuenta muestra el dinero que se espera recibir de los clientes, lo cual es esencial para la gestión del flujo de caja y la planificación financiera. [Consulta SQL](./workflow/accounts_receivable.sql)
- **Account Inventory**: Representa el inventario de la empresa. El inventario es un activo importante que puede convertirse en efectivo a través de ventas futuras. Su gestión eficiente es clave para la rentabilidad. [Consulta SQL](./workflow/account_inventory.sql)
- **Account Property and Equipment**: Representa la propiedad y el equipo. Estos son activos a largo plazo que la empresa utiliza para sus operaciones. La depreciación de estos activos también se considera para reflejar su valor real a lo largo del tiempo. [Consulta SQL](./workflow/account_property_equipment.sql)
- **Account Loan**: Representa los préstamos de la empresa. Esta cuenta es importante para entender las obligaciones de deuda de la empresa y su impacto en la liquidez y solvencia. [Consulta SQL](./workflow/account_loan.sql)
- **Account Retained Earnings Details**: Detalles de las ganancias retenidas. Esta cuenta muestra las ganancias acumuladas que no se han distribuido como dividendos y se reinvierten en la empresa. Es un indicador clave de la salud financiera a largo plazo. [Consulta SQL](./workflow/account_retained_earnings_details.sql)

## Capturas de Pantalla

Aquí tienes algunas capturas de pantalla de las vistas materializadas:

![Balance General](workflow\soportes\MATERIALIZED_VIEW_balance_sheet.png)
*Figura 1: Balance General generado por el proyecto.*

![Estado de Resultados](workflow\soportes\MATERIALIZED_VIEW_income_statement.png)
*Figura 2: Estado de Resultados generado por el proyecto.*

## Diagrama del Flujo de Trabajo

A continuación, se muestra un diagrama que ilustra el flujo de trabajo del proyecto:

![Flujo de Trabajo](./workflow/soportes/Proceso%20de%20Generación%20de%20Informes%20Financieros.png)*Figura 3: Diagrama del flujo de trabajo del proyecto.*

## Consideraciones Adicionales

A continuación, se presentan algunas consideraciones importantes sobre el mantenimiento y las ideas que se pueden obtener del balance general y el estado de resultados:

- **Legibilidad del código**: Es crucial que el código sea fácil de entender para otros y para nosotros mismos en el futuro. Utilizar CTE (Common Table Expressions) facilita la lectura del código.
- **Actualización de vistas**: Es importante tener un proceso que garantice que las vistas de cuentas se actualicen antes que las vistas de secciones, y estas antes que el informe del balance general. Este proceso debe estar documentado y, preferiblemente, automatizado por un equipo de ingeniería de datos.
- **Métricas financieras**:
  - **Balance General**: 
    - **Ratio de Liquidez**: Mide la capacidad de la empresa para cubrir sus obligaciones a corto plazo. [Más información](https://www.investopedia.com/terms/l/liquidityratios.asp)
    - **Ratio de Deuda a Activos**: Indica la proporción de los activos de la empresa que se financia con deuda. [Más información](https://www.investopedia.com/terms/d/debtratio.asp)
    - **Activos Netos Corrientes**: Diferencia entre los activos corrientes y los pasivos corrientes. [Más información](https://www.investopedia.com/terms/n/netcurrentassets.asp)
  - **Estado de Resultados**:
    - **Margen Bruto**: Mide la rentabilidad de las ventas después de deducir los costos directos. [Más información](https://www.investopedia.com/terms/g/grossmargin.asp)
    - **Crecimiento de los Ingresos**: Indica el aumento porcentual de los ingresos en un período determinado. [Más información](https://www.investopedia.com/terms/r/revenuegrowthrate.asp)
    - **Retorno sobre Ventas (ROS)**: Mide la eficiencia con la que la empresa convierte las ventas en ganancias. [Más información](https://www.investopedia.com/terms/r/returnonsales.asp)

Para más detalles, puedes consultar el archivo [Notes.md](./workflow/Notes.md), el cual presenta un transcrito de las consideraciones finales del curso SQL for Finance: Income Statement Project impartido por Gabriela Baldivia Soncini.

## Conclusión

Este proyecto no solo te enseña a generar dos de los informes financieros más importantes, sino que también te permite extraer métricas que ayudan a los interesados a comprender mejor el negocio y tomar decisiones más informadas. Además, las técnicas y consultas utilizadas en este proyecto pueden aplicarse en otras áreas de la planificación financiera, como la gestión del flujo de caja, la evaluación de inversiones y la planificación presupuestaria.

## Contribuciones

Este proyecto no está abierto a contribuciones externas, ya que es un fork de materiales proporcionados por LinkedIn Learning. Sin embargo, si encuentras algún problema o tienes sugerencias, puedes abrir un [issue](https://github.com/issues) para discutirlo.

## Instalación y Uso

Para ejecutar este proyecto, sigue estos pasos:

1. **Requisitos previos**:
   - Instala PostgreSQL desde [aquí](https://www.postgresql.org/download/).
   - Crea una base de datos y ejecuta el script [setup-postgresql.sql](.\.devcontainer\setup-postgresql.sql) para crear las tablas necesarias.

2. **Ejecutar las consultas SQL**:
   - Copia y pega las consultas SQL proporcionadas en este README en tu herramienta de gestión de bases de datos (por ejemplo, pgAdmin o psql).
   - Ejecuta las consultas para generar las vistas materializadas y obtener los informes financieros.

3. **Verificar los resultados**:
   - Revisa las tablas de salida proporcionadas en este README para asegurarte de que los resultados sean los esperados.

## Licencia

Este proyecto es un fork de los materiales proporcionados como parte de un curso de LinkedIn Learning. Los archivos originales están sujetos a los términos de la **Licencia de Archivos de Ejercicios de LinkedIn Learning**, que se describe a continuación:

### Términos de la Licencia

1. **Uso permitido**:
   - Puedes usar, copiar y modificar los materiales de este proyecto con fines educativos y de práctica personal, siempre y cuando tengas una suscripción activa a LinkedIn Learning.
   - Puedes distribuir este proyecto como parte de tu portafolio personal para demostrar tus habilidades a empleadores o en entrevistas de trabajo.

2. **Restricciones**:
   - No puedes incluir estos materiales en productos o servicios comerciales.
   - No puedes usar estos materiales para enseñar o educar a otros sin el consentimiento explícito de LinkedIn.

3. **Propiedad intelectual**:
   - LinkedIn Corporation conserva todos los derechos de propiedad intelectual sobre los materiales originales del curso.
   - Cualquier modificación o contribución que hagas a este proyecto se licencia bajo los términos de la **Licencia BSD 2-Clause**.

4. **Atribuciones**:
   - Este proyecto utiliza la biblioteca **psycopg2**, que está licenciada bajo la **GNU Lesser General Public License (LGPL)**. Puedes encontrar más información sobre esta licencia en el archivo [Notice](./NOTICE).

### Licencia BSD 2-Clause

El código modificado y las contribuciones realizadas en este proyecto están licenciados bajo la **Licencia BSD 2-Clause**, que permite el uso, modificación y distribución del código con las siguientes condiciones:

- Debes incluir una copia de la licencia y el aviso de copyright original en cualquier distribución del código.
- No puedes usar el nombre del proyecto o de los contribuyentes para promocionar productos derivados sin permiso explícito.

## Aviso Legal

Este proyecto es un fork de materiales proporcionados por LinkedIn Learning. No estoy afiliado a LinkedIn Corporation, y este proyecto es solo una demostración de mis habilidades técnicas. Para más detalles sobre los términos de uso, consulta el archivo [License](./LICENSE).


### Enlaces relevantes

- [Licencia de LinkedIn Learning](./LICENSE)
- [Aviso de licencia de psycopg2](./NOTICE)
- [Licencia BSD 2-Clause](https://opensource.org/licenses/BSD-2-Clause)
- [SQL for Finance: Income Statement Project](https://www.linkedin.com/learning-login/share?forceAccount=false&redirect=https%3A%2F%2Fwww.linkedin.com%2Flearning%2Fsql-for-finance-income-statement-project%3Ftrk%3Dshare_ent_url%26shareId%3DamGUtib2Sam1uiEcGqiYSg%253D%253D) (Curso consultado)
- [Gabriela Baldivia Soncini](https://www.linkedin.com/in/gbaldiviasoncini) (Instructora del curso)