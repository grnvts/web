import React from 'react'
import ApiService from "../Services/BaseService/ApiService";
import { useTranslation  } from 'react-i18next';

const LanguageSelector = (props) => {

    const { /*t,*/ i18n} = useTranslation();
    
    const onchangeLanguage = lg => {
        //const { i18n } = props;
        i18n.changeLanguage(lg);
        ApiService.changeLanguage(lg);

    };

    return (
        <div className="col-sm-12">

            <img
                src="https://flagcdn.com/32x24/ru.png"
                style={{ cursor: "pointer" }}
                onClick={() => onchangeLanguage("ru")}
                alt="Russian Flag"
                title="Русский"
            />
            <img
                src="https://flagcdn.com/32x24/gb.png"
                style={{ cursor: "pointer", marginLeft: "10px" }}
                onClick={() => onchangeLanguage("en")}
                alt="UK Flag"
                title="English"
            />
            <hr />
        </div>
    );
};
export default LanguageSelector;
//export default withTranslation()(LanguageSelector);
